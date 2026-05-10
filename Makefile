# 変数定義
VENV_NAME := venv_omnivla
PYTHON := ./$(VENV_NAME)/bin/python3
PIP := ./$(VENV_NAME)/bin/pip

.PHONY: help setup build run clean

help:
	@echo "利用可能なコマンド:"
	@echo "  make setup   - 仮想環境の作成、AI本体(extern)の取得、ライブラリのインストール"
	@echo "  make build   - ROS 2パッケージのビルド"
	@echo "  make clean   - ビルド成果物(build, install, log)の削除"
	@echo " 仮想環境を起動する際は"source venv_omnivla/bin/activate", 終了する際は"deactivate"を入力"
# 1. 環境セットアップ
setup:
	@echo "--- 仮想環境を作成中 ---"
	python3 -m venv $(VENV_NAME) --system-site-packages
	@echo "--- 必要なリポジトリを取得中 ---"
	mkdir src && cd src && git clone git@github.com:wadajun8/camera_server.git && git clone git@github.com:wadajun8/vla_server.git
	mkdir extern && cd extern && git clone https://github.com/NHirose/OmniVLA.git
	mkdir models && cd models && git clone https://huggingface.co/NHirose/omnivla-edge
	@echo "--- ライブラリをインストール中 ---"
	$(PIP) install -r requirements.txt --ignore-installed
	cat << 'EOF' >> venv_omnivla/bin/activate
	# --- OmniVLA & ROS 2 汎用自動設定 ---
	# このファイル(activate)の場所からワークスペースのルートを特定
	VENV_BIN_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
	WS_ROOT=$(dirname "$(dirname "$VENV_BIN_DIR")")
	export PYTHONNOUSERSITE=1
	# 自分のPCでも他者のPCでも動くように相対的にパスを設定
	export PYTHONPATH="$WS_ROOT/venv_omnivla/lib/python3.10/site-packages:$PYTHONPATH"
	# システムのROS 2設定
	source /opt/ros/humble/setup.bash
	# ビルド済みパッケージがあれば読み込む
	if [ -f "$WS_ROOT/install/setup.bash" ]; then
	    source "$WS_ROOT/install/setup.bash"
	fi
	echo "OmniVLA environment is ready! (Universal configuration applied)"
	EOF
	@echo "--- 設定完了 ---"


# 2. ROS 2 ビルド
build:
	@echo "--- ビルド中 ---"
	touch $(VENV_NAME)/COLCON_IGNORE
	bash -c "source /opt/ros/humble/setup.bash && colcon build --packages-select camera_server vla_server"


# 4. 掃除
clean:
	rm -rf build install log
