include conf/config.mk

.PHONY: all floppy_image boot clean always run

all: floppy_image

include conf/toolchain.mk

floppy_image: $(BUILD_DIR)/Leaf-Legacy.img

$(BUILD_DIR)/Leaf-Legacy.img: boot
	@dd if=/dev/zero of=$@ bs=512 count=2880
	@mkfs.fat -F 12 -n "LEAF" $@
	@dd if=$(BUILD_DIR)/stage1.bin of=$@ conv=notrunc
	@mcopy -i $@ $(BUILD_DIR)/stage2.bin "::stage2.bin"
	@mcopy -i $@ test.txt "::test.txt"

boot: stage1 stage2

stage1: $(BUILD_DIR)/stage1.bin

$(BUILD_DIR)/stage1.bin: always
	@$(MAKE) -C boot/stage1 BUILD_DIR=$(abspath $(BUILD_DIR))

stage2: $(BUILD_DIR)/stage2.bin

$(BUILD_DIR)/stage2.bin: always
	@$(MAKE) -C boot/stage2 BUILD_DIR=$(abspath $(BUILD_DIR))

run: floppy_image
	@$(QEMU) $(QEMU_FLAGS) -drive format=raw,file=$(BUILD_DIR)/Leaf-Legacy.img

always:
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(BUILD_DIR)/stage2

clean:
	@$(MAKE) -C boot/stage1 BUILD_DIR=$(abspath $(BUILD_DIR)) clean
	@$(MAKE) -C boot/stage2 BUILD_DIR=$(abspath $(BUILD_DIR)) clean
	@rm -rf $(BUILD_DIR)/*
