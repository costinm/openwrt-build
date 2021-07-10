TARGET?=10.1.10.59
WRT_SRC?=/y/openwrt/

deps:
	docker pull openwrtorg/sdk:latest

CMD=docker run -it -w /home/user/openwrt --rm -v ${WRT_SRC}:/home/user/openwrt \
    		-v /ws/openwrt-build:/home/user/openwrt-build \
    		openwrtorg/sdk

# Get a shell in the build machine
docker/sh:
	# -u $(shell id -u)
	${CMD}

docker/update:
	${CMD} ./scripts/feeds update -a
	${CMD} ./scripts/feeds install -a
	cp x86.config ${WRT_SRC}/openwrt/.config

	${CMD} make defconfig
	#./scripts/diffconfig.sh > costin-x86-2021-07-1.diffconfig
	# make menuconfig
	${CMD} make -j8

deploy:
	scp ${WRT_SRC}/openwrt/bin/targets/x86/64/openwrt-x86-64-generic-ext4-combined-efi.img.gz root@${TARGET}:/tmp
	ssh root@${TARGET} sysupgrade /tmp/openwrt-x86-64-generic-ext4-combined-efi.img.gz
