BUILD_DIR?=build/

TARGET_ASMFLAGS += 
TARGET_CFLAGS += -std=gnu99 -ffreestanding -O2 -Wall -Wextra -nostartfiles -nostdlib -lgcc -Iinclude/ -I.
TARGET_LIBS += -lgcc -Iinclude/ -I.
TARGET_LINKFLAGS += -T linker.ld -ffreestanding -O2 -nostdlib 

SOURCES_ASM=$(shell find -L * -type f -name '*.asm')
SOURCES_C=$(shell find -L * -type f -name '*.c')
OBJECTS_C=$(patsubst %.c, $(BUILD_DIR)/stage2/%.o, $(SOURCES_C))
OBJECTS_ASM=$(patsubst %.asm, $(BUILD_DIR)/stage2/%.o, $(SOURCES_ASM))


OBJS := $(OBJECTS_ASM) $(OBJECTS_C)

.PHONY: all clean

all: stage2

stage2: $(BUILD_DIR)/stage2.bin

$(BUILD_DIR)/stage2.bin: $(OBJS) linker.ld
	@printf "  LD $@\n"
	@$(TARGET_CC) $(TARGET_LINKFLAGS) -o $@ $(OBJS) $(TARGET_LIBS)

$(BUILD_DIR)/stage2/%.o: %.asm
	@printf "  AS $<\n"
	@mkdir -p $(dir $@)
	@$(TARGET_ASM) $< $(TARGET_ASMFLAGS) -o $@

$(BUILD_DIR)/stage2/%.o: %.c
	@printf "  CC $<\n"
	@mkdir -p $(dir $@)
	@$(TARGET_CC) $(TARGET_CFLAGS) -c $< -o $@

clean:
	@rm -f $(BUILD_DIR)/stage2.bin $(OBJS)