build_entry := ./scripts/entry.sh

.PHONY: defconfig %_defconfig config build clean distclean

default_target: build

defconfig:
	$(build_entry) defconfig raspi3

%_defconfig:
	$(build_entry) defconfig $*

config:
	$(build_entry) config

build:
	$(build_entry) build

clean:
	$(build_entry) clean

distclean:
	$(build_entry) distclean
