# Building custom openwrt 

I use an x86 box for openwrt, with docker and few other packages. Instead of installing 
manually different packagee. A couple of cheap Wifi access points, in bridge 
mode are also running custom builds.

# TODO

[] EFI or boot loader to prefer a USB stick, if present. 
This would allow recovery. Ideally a key or signature could be used.
On x86 this is simple - for MIPS it would be an alternative
to A/B safe upgrade.

[] For x86, auto create a partition at the end of the stick, and auto-mount
other volumes. This seems possible using the configs.


## Building

```shell
docker pull openwrtorg/sdk

# In the docker image:

git clone  https://github.com/openwrt/openwrt

./scripts/feeds update -a
./scripts/feeds install -a

cp ../...  .config
make defconfig

make image PROFILE=x86/64 PACKAGES="" IGNORE_ERRORS=1

# On host:
scp /ws/openwrt/openwrt/bin/targets/ath79/generic/openwrt-ath79-generic-tplink_tl-wdr3600-v1-squashfs-sysupgrade.bin \
  root@192.168.1.1:/tmp/
scp /ws/openwrt/openwrt/bin/targets/x86/64/openwrt-x86-64-generic-ext4-combined-efi.img.gz \
  wrt1:/tmp

```

# Issues

- luci broken after restore -> fix /etc/config/rpcd
-
