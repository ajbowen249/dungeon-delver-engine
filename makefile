ZASM := "zasm"

SRC_DIR := ./src
BUILD_DIR := ./build

ASM_FILES := $(SRC_DIR)/**/*.asm $(SRC_DIR)/*.asm $(SRC_DIR)/**/**/*.asm

# campaign for testing, not to be confused with the test binary
TEST_CAMPAIGN_ROOT_FILE := $(SRC_DIR)/entry_points/test_campaign.asm
TEST_CAMPAIGN_OUTPUT := $(BUILD_DIR)/test_campaign.hex

# unit tests
TESTS_ROOT_FILE := $(SRC_DIR)/entry_points/tests.asm
TESTS_OUTPUT := $(BUILD_DIR)/tests.hex

.PHONY: all
.SUFFIXES:
.PRECIOUS: $(BUILD_DIR)/%.hex $(BUILD_DIR)/%.lst $(BUILD_DIR)/%.rom

all: $(TEST_CAMPAIGN_OUTPUT) $(TESTS_OUTPUT)

test_campaign: $(TEST_CAMPAIGN_OUTPUT)
test: $(TESTS_OUTPUT)

STR_BUILD:=build
STR_CAMPAIGNS:=$(SRC_DIR)/entry_points

$(BUILD_DIR)/%.hex: $(ASM_FILES)
	@mkdir -p $(BUILD_DIR)
	$(ZASM) --8080 -x $(subst .hex,.asm, $(subst $(STR_BUILD),$(STR_CAMPAIGNS),$@)) -o $(BUILD_DIR)

clean:
	@rm -rfv $(BUILD_DIR)
