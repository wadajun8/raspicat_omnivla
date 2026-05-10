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
	mkdir -p src
	cd src && (git clone git@github.com:wadajun8/camera_server.git || true)
	cd src && (git clone git@github.com:wadajun8/vla_server.git || true)
	mkdir -p extern
	cd extern && (git clone https://github.com/NHirose/OmniVLA.git || true)
	mkdir -p models
	cd models && (git clone https://huggingface.co/NHirose/omnivla-edge || true)
	@echo "--- ライブラリをインストール中 ---"
	$(PIP) install -r requirements.txt --ignore-installed
	@echo "--- 仮想環境に自動設定を書き込み中 ---"
	@echo 'VENV_BIN_DIR=$$(cd "$$(dirname "$${BASH_SOURCE[0]}")" && pwd)' > extra_cfg.tmp
	@echo 'WS_ROOT=$$(dirname "$$(dirname "$$VENV_BIN_DIR")")' >> extra_cfg.tmp
	@echo 'export PYTHONNOUSERSITE=1' >> extra_cfg.tmp
	@echo 'export PYTHONPATH="$$WS_ROOT/$(VENV_NAME)/lib/python3.10/site-packages:$$PYTHONPATH"' >> extra_cfg.tmp
	@echo '. /opt/ros/humble/setup.bash' >> extra_cfg.tmp
	@echo 'if [ -f "$$WS_ROOT/install/setup.bash" ]; then . "$$WS_ROOT/install/setup.bash"; fi' >> extra_cfg.tmp
	@echo 'echo "OmniVLA environment is ready!"' >> extra_cfg.tmp
	@cat extra_cfg.tmp >> $(VENV_NAME)/bin/activate
	@rm extra_cfg.tmp
	@echo "書き込み完了"
# 2. ROS 2 ビルド
build:
	@echo "--- ビルド中 ---"
	touch $(VENV_NAME)/COLCON_IGNORE
	bash -c "source /opt/ros/humble/setup.bash && colcon build --packages-select camera_server vla_server"


# 4. 掃除
clean:
	rm -rf build install log
