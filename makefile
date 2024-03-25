ZASM := "zasm"
PYTHON := "python"

TOOLS_DIR := ./tools
SRC_DIR := ./src
APP_SRC_DIR := $(SRC_DIR)/apps
BUILD_DIR := ./build

GENERATED_FOLDER := $(BUILD_DIR)/generated
COMPRESSED_ENGINE_TEXT := $(GENERATED_FOLDER)/compressed_text.asm

APPS := $(wildcard $(SRC_DIR)/apps/*)
APP_NAMES := $(foreach app,$(APPS),$(subst $(APP_SRC_DIR)/,, $(app)))
APP_OUTPUT_FILES := $(foreach app, $(APP_NAMES), $(BUILD_DIR)/$(app).hex)

.PRECIOUS: $(BUILD_DIR)/%.hex

all: $(COMPRESSED_ENGINE_TEXT) $(APP_OUTPUT_FILES)

test: build/tests.hex
compressed_text: $(COMPRESSED_ENGINE_TEXT)

$(COMPRESSED_ENGINE_TEXT):
	@mkdir -p $(GENERATED_FOLDER)
	$(PYTHON) $(TOOLS_DIR)/compressor -o $(COMPRESSED_ENGINE_TEXT)

$(BUILD_DIR)/%.hex: $(COMPRESSED_ENGINE_TEXT) $(SRC_DIR)/**/*.asm $(SRC_DIR)/**/**/*.asm
	@mkdir -p $(BUILD_DIR)
	$(ZASM) --8080 -x $(patsubst %.hex,%/main.asm,$(subst build,src/apps,$@)) -o $@

clean:
	@rm -rfv $(BUILD_DIR)
