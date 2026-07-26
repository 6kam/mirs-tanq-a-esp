# ============================================================
#  MIRS ESP32 ファームウェア — arduino-cli 用 Makefile
# ============================================================
#
#  使い方:
#    make              # コンパイル + アップロード
#    make compile      # コンパイルのみ
#    make upload       # アップロードのみ (要事前コンパイル)
#    make monitor      # シリアルモニタ
#    make clean        # ビルド成果物を削除
#    make install-lib  # micro_ros_arduino ライブラリをリンク
#    make info         # ボード・ポート情報を表示
#
#  ポート指定:
#    make upload PORT=/dev/ttyUSB0
#
# ============================================================

# --- 設定 -----------------------------------------------------------

# スケッチディレクトリ (*.ino があるフォルダ)
SKETCH_DIR   := $(CURDIR)/mirs26-esp32

# ボード FQBN (ESP32 Dev Module)
FQBN         := esp32:esp32:esp32

# シリアルポート (自動検出 or 手動指定)
PORT         ?= $(shell arduino-cli board list 2>/dev/null \
                  | grep -i 'esp32\|CP210\|CH340\|ttyUSB' \
                  | head -1 | awk '{print $$1}')

# ボーレート (モニタ用)
BAUD         ?= 115200

# micro_ros_arduino ライブラリのパス
MICRO_ROS_LIB := $(realpath $(CURDIR)/../micro_ros_arduino)

# Arduino ユーザーライブラリディレクトリ
ARDUINO_LIB_DIR := $(HOME)/Arduino/libraries

# ライブラリのシンボリックリンク名
LIB_LINK_NAME := micro_ros_arduino

# ビルド出力ディレクトリ
BUILD_DIR    := $(CURDIR)/build

# arduino-cli 共通フラグ
CLI_FLAGS    := --fqbn $(FQBN) --build-path $(BUILD_DIR)

# --- ターゲット ------------------------------------------------------

.PHONY: all compile upload monitor clean install-lib uninstall-lib info help

## デフォルト: コンパイル → アップロード
all: compile upload

## コンパイル
compile: _check-lib
	@echo ""
	@echo "========================================"
	@echo "  コンパイル中..."
	@echo "  スケッチ: $(SKETCH_DIR)"
	@echo "  ボード:   $(FQBN)"
	@echo "========================================"
	@echo ""
	arduino-cli compile $(CLI_FLAGS) $(SKETCH_DIR)
	@echo ""
	@echo "✅ コンパイル完了"

## アップロード
upload: _check-port
	@echo ""
	@echo "========================================"
	@echo "  アップロード中..."
	@echo "  ポート:   $(PORT)"
	@echo "  ボード:   $(FQBN)"
	@echo "========================================"
	@echo ""
	arduino-cli upload --fqbn $(FQBN) --port $(PORT) --input-dir $(BUILD_DIR) $(SKETCH_DIR)
	@echo ""
	@echo "✅ アップロード完了"

## シリアルモニタ
monitor: _check-port
	@echo "シリアルモニタ起動 ($(PORT) @ $(BAUD)bps)  Ctrl+C で終了"
	arduino-cli monitor --port $(PORT) --config baudrate=$(BAUD)

## ビルド成果物を削除
clean:
	@echo "ビルドディレクトリ削除: $(BUILD_DIR)"
	rm -rf $(BUILD_DIR)
	@echo "✅ クリーン完了"

## micro_ros_arduino ライブラリをシンボリックリンクでインストール
install-lib:
	@if [ ! -d "$(MICRO_ROS_LIB)" ]; then \
		echo "❌ エラー: micro_ros_arduino が見つかりません: $(MICRO_ROS_LIB)"; \
		exit 1; \
	fi
	@mkdir -p $(ARDUINO_LIB_DIR)
	@if [ -L "$(ARDUINO_LIB_DIR)/$(LIB_LINK_NAME)" ]; then \
		echo "既存のシンボリックリンクを更新します"; \
		rm -f "$(ARDUINO_LIB_DIR)/$(LIB_LINK_NAME)"; \
	fi
	ln -s $(MICRO_ROS_LIB) $(ARDUINO_LIB_DIR)/$(LIB_LINK_NAME)
	@echo "✅ ライブラリリンク作成: $(ARDUINO_LIB_DIR)/$(LIB_LINK_NAME) → $(MICRO_ROS_LIB)"

## ライブラリリンクを削除
uninstall-lib:
	rm -f $(ARDUINO_LIB_DIR)/$(LIB_LINK_NAME)
	@echo "✅ ライブラリリンク削除"

## 環境情報を表示
info:
	@echo "=== Arduino CLI ==="
	arduino-cli version
	@echo ""
	@echo "=== インストール済みコア ==="
	arduino-cli core list
	@echo ""
	@echo "=== インストール済みライブラリ ==="
	arduino-cli lib list
	@echo ""
	@echo "=== 接続中のボード ==="
	arduino-cli board list
	@echo ""
	@echo "=== 設定値 ==="
	@echo "  SKETCH_DIR:    $(SKETCH_DIR)"
	@echo "  FQBN:          $(FQBN)"
	@echo "  PORT:          $(or $(PORT),(未検出))"
	@echo "  MICRO_ROS_LIB: $(MICRO_ROS_LIB)"
	@echo "  BUILD_DIR:     $(BUILD_DIR)"

## ヘルプ
help:
	@echo "使い方: make [ターゲット] [PORT=/dev/ttyUSBx]"
	@echo ""
	@echo "ターゲット:"
	@echo "  all           コンパイル + アップロード (デフォルト)"
	@echo "  compile       コンパイルのみ"
	@echo "  upload        アップロードのみ"
	@echo "  monitor       シリアルモニタ"
	@echo "  clean         ビルド成果物を削除"
	@echo "  install-lib   micro_ros_arduino ライブラリをリンク"
	@echo "  uninstall-lib ライブラリリンクを削除"
	@echo "  info          環境情報を表示"
	@echo "  help          このヘルプを表示"

# --- 内部チェック ----------------------------------------------------

_check-port:
	@if [ -z "$(PORT)" ]; then \
		echo "❌ エラー: ESP32 のポートが検出できません"; \
		echo "  → make upload PORT=/dev/ttyUSB0 のように指定してください"; \
		echo "  → arduino-cli board list で確認できます"; \
		exit 1; \
	fi

_check-lib:
	@if [ ! -L "$(ARDUINO_LIB_DIR)/$(LIB_LINK_NAME)" ] && \
	    ! arduino-cli lib list 2>/dev/null | grep -qi 'micro_ros'; then \
		echo "⚠️  micro_ros_arduino ライブラリが見つかりません"; \
		echo "  → make install-lib を実行してください"; \
	fi
