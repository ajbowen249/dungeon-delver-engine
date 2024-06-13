ZASM := "zasm"
PYTHON := "python"

TOOLS_DIR := ./tools
SRC_DIR := ./src
APP_SRC_DIR := $(SRC_DIR)/apps
BUILD_DIR := ./build

ENGINE_TEXT_FILE := $(TOOLS_DIR)/compressor/engine_text.json
GENERATED_FOLDER := $(BUILD_DIR)/generated
COMPRESSED_ENGINE_TEXT := $(GENERATED_FOLDER)/compressed_text.asm

APPS := $(wildcard $(SRC_DIR)/apps/*)
APP_NAMES := $(foreach app,$(APPS),$(subst $(APP_SRC_DIR)/,, $(app)))
APP_OUTPUT_FILES := $(foreach app, $(APP_NAMES), $(BUILD_DIR)/$(app).hex $(BUILD_DIR)/$(app).co)
ALL_SRC_ASM := $(call rwildcard,$(SRC_DIR)/,*.asm)

.PRECIOUS: $(BUILD_DIR)/%.hex $(BUILD_DIR)/%.co

all: $(COMPRESSED_ENGINE_TEXT) $(APP_OUTPUT_FILES)

test: build/tests.hex
compressed_text: $(COMPRESSED_ENGINE_TEXT)

$(COMPRESSED_ENGINE_TEXT): $(ENGINE_TEXT_FILE)
	@mkdir -p $(GENERATED_FOLDER)
	$(PYTHON) $(TOOLS_DIR)/compressor -o $(COMPRESSED_ENGINE_TEXT)

$(BUILD_DIR)/%.hex: $(COMPRESSED_ENGINE_TEXT) $(ALL_SRC_ASM)
	@mkdir -p $(BUILD_DIR)
	$(ZASM) --8080 -x $(patsubst %.hex,%/main.asm,$(subst build,src/apps,$@)) -o $@

$(BUILD_DIR)/%.co: $(COMPRESSED_TEXT) $(ALL_SRC_ASM)
	@mkdir -p $(BUILD_DIR)
	$(ZASM) --8080 $(patsubst %.co,%/main.asm,$(subst build,src/apps,$@)) -o $@.obj
	@perl -e ' print pack "S<", 45568 ' > $@.hdr
	@perl -e ' print pack "S<", -s "$@.obj" ' >> $@.hdr
	@perl -e ' print pack "S<", 45568 ' >> $@.hdr
	@cat $@.hdr $@.obj > $@

clean:
	@rm -rfv $(BUILD_DIR)
