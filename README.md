# ほぼメモ
## OmniVLAについて
- Conda環境のセットアップ等はOmniVLAのREADMEを参照して
- モデルの重みの位置とか変えてるから気をつけて
```
raspicat_omnivla/
├── src/                # ROS 2の自作パッケージ（自作のコード）
│   ├── camera_server/
│   └── vla_server/     # VLAノード
├── extern/             # 外部のGitリポジトリ（他人が作ったコード）
│   ├── OmniVLA/        # Cloneした本体コード
│   └── lerobot/        # (将来的にいれたい） データ読み込み用ツール
├── models/             # AIモデル（重みファイル）本体
│   └── omnivla-edge/   
└── datasets/           # (将来的に入れたい) 学習用の巨大なデータ群
    ├── LeLaN/
    └── GNM/
```

- extern/OmniVLA/inference/run\_omnivla\_edge.pyを使うときCLIPが必要っぽい
```
pip install git+https://github.com/openai/CLIP.git
```
- OmniVLAのreadmeと違うディレクトリ(models)にmodelの重みをおいたのでMODEL\_WEIGHTS\_PATHを変更してる
```
# run_omnivla_edge.pyがあるディレクトリのパスを取得
current_dir = os.path.dirname(os.path.abspath(__file__))

# そこから3階層上がって models/omnivla-edge につなぎ、綺麗な絶対パスに自動変換する
MODEL_WEIGHTS_PATH = os.path.abspath(os.path.join(current_dir, "../../../models/omnivla-edge"))
```

## 必要なノードとsetup
- camera\_server（2026/05/08現在プライベート）
- vla\_server
```
git clone git@github.com:wadajun8/raspaicat_omnivla.git
cd raspicat_omnivla && mkdir src && cd src
git@github.com:wadajun8/camera_server.git
git@github.com:wadajun8/vla_server.git
cd ..
colcon build --packages-select camera_server vla_server
source install/setup.bash
```

## 実行
- 2つのターミナルでそれぞれを起動(今後launchファイルを作りたい！)
```
ros2 run camera_server camera_node
```
```
ros2 run vla_server vla_node INITIAL INSTRUCTION
```

- raspicat側では以下の2つを別々のターミナルで打つ（たぶん! まだやってない）
```
ros2 launch raspicat raspicat.launch.py
```
```
ros2 service call /motor_power std_srvs/SetBool '{data: true}'
```
- 指示を更新するならこれ
```
ros2 topic pub -1 /vla/instruction std_msgs/msg/String "{data: 'UPDATE INSTRUCTION'}"
```
