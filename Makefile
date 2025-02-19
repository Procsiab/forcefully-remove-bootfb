KDIR ?= /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)
BUILD_DIR ?= $(PWD)/build
BUILD_DIR_MAKEFILE ?= $(PWD)/build/Makefile
DKMS_MAKEFILE ?= $(PWD)/Makefile

default: $(BUILD_DIR_MAKEFILE)
	make -C $(KDIR) M=$(BUILD_DIR) src=$(PWD) modules

dkms: $(DKMS_MAKEFILE)
	make -C $(KDIR) M=$(PWD) src=$(PWD) modules

$(BUILD_DIR):
	mkdir -p "$@"

$(BUILD_DIR_MAKEFILE): $(BUILD_DIR)
	touch "$@"

clean:
	make -C $(KDIR) M=$(BUILD_DIR) src=$(PWD) clean

dkms-clean:
	make -C $(KDIR) M=$(PWD) src=$(PWD) clean

install:
	make -C $(KDIR) M=$(BUILD_DIR) modules_install
