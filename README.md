
ros2 humble用
arduino ide or arduino cli用

ESP32でmicro_ros_arduinoを使うプログラム。mirs240xの不具合の修正版

Arduino IDE に以下のソースコード、ライブラリ、ボードマネージャーを導入します。

- ESP32 用ソースコード：[mirs_esp](https://github.com/mirs260x/mirs_esp)
（参考：[mirs240x/mirs24_esp32](https://github.com/mirs240x/mirs24_esp32.git)）

- micro-ROS ライブラリをzipでインポートする：[micro_ros_arduino_mirs240x](https://github.com/mirs240x/micro_ros_arduino_mirs240x)

- ボードマネージャは esp32（Espressif Systems著）バージョン 2.x 系を導入し、導入後、ボードはESP32ならば **ESP32 Dev Module** を選択してください。

esp32を接続し、ソースコードをコンパイル、送信してください。

ros2で通信するにはmicro_ros_agentパッケージが必要になります。
