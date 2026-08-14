# mirs_esp

ROS 2 Humble向け、Arduino IDE / Arduino CLI用のESP32ファームウェアです。

## Arduino IDEでの書き込み

### 1. ソースコードを取得

```bash
git clone https://github.com/mirs260x/mirs_esp.git
```

### 2. micro-ROSライブラリを追加

[micro_ros_arduino_mirs240x](https://github.com/mirs240x/micro_ros_arduino_mirs240x) をZIPでダウンロードし、Arduino IDEの **Sketch → Include Library → Add .ZIP Library...** から追加します。

### 3. ボードを設定

Arduino IDEのボードマネージャで、Espressif Systemsの `esp32` 2.x系をインストールします。使用ボードは **ESP32 Dev Module** を選択します。

### 4. 書き込み

ESP32を接続し、`mirs_esp` のソースコードを開いてコンパイル・書き込みします。

## ROS 2との接続

ESP32とROS 2をmicro-ROSで接続するには、ROS 2側でmicro-ROS Agentを起動します。Agentの起動方法やDockerの操作は、それぞれのリポジトリを参照してください。

- ROS 2パッケージの使い方: [mirs](https://github.com/mirs260x/mirs)
- Dockerの起動・終了: [mirs_container](https://github.com/mirs260x/mirs_container)
