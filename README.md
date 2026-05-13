# ROS2でOmniVLA-edgeを使用するためのリポジトリ
[OmniVLA](https://github.com/NHirose/OmniVLA)-edgeでカメラから取得した画像と言語指示に基づいた自律移動を行うためのワークスペースです。  
[vla_server](https://github.com/wadajun8/vla_server)と[camera_server](https://github.com/wadajun8/camera_server)を使います。

## setup
```
git clone git@github.com:wadajun8/raspicat_omnivla.git
cd raspicat_omnivla
make setup
source venv_omnivla/bin/activate
colcon build --packages-select camera_server vla_server
source install/setup.bash
```
## 実行
- 2つのターミナルでそれぞれを起動(今後launchファイルを作りたい！)
  - 先に環境を読み込んでソースしてから
```
source venv_omnivla/bin/activate
source install/setup.bash
```
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
## ディレクトリ構造
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
## ライセンス
- このリポジトリは3条項BSDライセンスのもとで公開されています。
