ZASM := "zasm"

SRC_DIR := ./src
BUILD_DIR := ./build

ROOT_INPUT_FILE := $(SRC_DIR)/dde.asm

HEX_FILE_OUTPUT := $(BUILD_DIR)/dde.hex

.PHONY: all
.SUFFIXES:
.PRECIOUS: $(BUILD_DIR)/%.hex $(BUILD_DIR)/%.lst $(BUILD_DIR)/%.rom

hex: $(HEX_FILE_OUTPUT)

all: $(HEX_FILE_OUTPUT)

$(BUILD_DIR)/dde.hex:
	@mkdir -p $(BUILD_DIR)
	$(ZASM) --8080 -x $(ROOT_INPUT_FILE) -o $(BUILD_DIR)

clean:
	@rm -rfv $(BUILD_DIR)
