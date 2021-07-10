# General

- optimized for very low flash and RAM
- similar with docker - overlay, build root fs
- min: 4 M Flash /32 M RAM
- kernel 4.14 (alpine: 5.4.43)
- ubus - instead of dbus in alpine
- procd - apline is openrc
-

# Compared with alpine

- alpine has desktop - but hard to install, might be better to use a chromeos-like
- alpine bundles all firmware - 400M
- docker works too - but larger base
- deb-like upgrade, per package - openwrt is more like chromeos
- openwrt may be a better docker base


# TODO

- separate kernel from rootfs - mix alpine, android, chrome, openwrt kernels
with a common openwrt+alpine rootfs

- run/build alpine packages on openwrt
- same in reverse

- use the openwrt docker image as base - procd, etc

# Boot

Bootload: EFI partition, ~512M FAT32, on GPT with the expected part type


# Goal

- kernel from any distro, best for the device, with blobs
For example on android devices use latest android kernel+blobs
On routers use wrt kernel
On Pi use debian kernel
Use alpine where it has full support

- bootloader similar with openwrt (or alpine), managed by
separate script and with multiple rootfs partitions

- separate RO root partition - squash or ext4

- data/overlay as separate partition, not at the end

- separate /home and /srv, swap partitions

- multiple rootfs partitions - A/B, different OS



# Upgrade process

1. Download the flash image to tmpfs
2. Create a tar with the configs/to save
3. Flash in place - no A/B
4. On next book, restore the tar

It seems possible to use an extra partition or disk for
persistence.

The 'rootfs' and kernel will be replaced, may need hooks.

For x86/ext4 it may be possible to do rolling upgrade.
Kernel and modules are tied.

# Docker

Pre-init seems redundant.
Procd - should not enable hotplug ( in particular if
using parent namespace - it won't work)

# Unique features

- config model
- firewall and integration
- MUSL, like Alpine

# Startup

- pre-init
- start
ubusd -s /var/run/ubus.sock &
procd -S -d 255


# Image building

- for raw hardware
- packages are in squash image, ligher
- safe upgrade - opkg installs are not preserved nor safe
- like docker images !
- https://github.com/openwrt/docker
-

```

make image PROFILE=x86/64

echo $(opkg list_installed | awk '{ print $1 }')

luci-app-nft-qos

```

Rebuild (SDK):
TARGET_ROOTFS_PARTSIZE
16M boot, 256M rootfs

# Upgrade

listed by opkg list-changed-conffiles
listed within the text files in /lib/upgrade/keep.d/ (for example, /lib/upgrade/keep.d/base-files-essential)
listed in /etc/sysupgrade.conf


```

docker run --rm -v "/ws/openwrt:/home/build/openwrt/bin -it openwrtorg/imagebuilder -- \
  make image  PACKAGES="\
    kmod-bnx2 kmod-e1000e kmod-e1000 \
    iperf3 tcpdump luci tmux fdisk \
    collectd collectd-mod-conntrack \
    collectd-mod-cpu \
    collectd-mod-cpufreq \
    collectd-mod-dns \
    collectd-mod-ethstat \
    collectd-mod-interface \
    collectd-mod-iwinfo \
    collectd-mod-load \
    collectd-mod-memory \
    collectd-mod-network \
    collectd-mod-rrdtool \
    collectd-mod-vmem \
    e2fsprogs \
    kmod-ath9k-htc \
    iftop \
    luci-app-nft-qos \
    luci-app-statistics luci-app-vnstat" \
    IGNORE_ERRORS=1

scp /ws/openwrt/targets/x86/64/openwrt-x86-64-generic-ext4-combined.img.gz wrt55:/tmp
ssh  wrt55 sysupgrade /tmp/*.gz

docker run -it --rm -v /ws/openwrt:/home/user/openwrt openwrtorg/sdk

```

Build:

```

 make[1] world
 make[2] package/cleanup
 make[2] target/compile
 make[3] -C target/linux compile
 make[2] buildinfo
 make[2] package/compile

|le
```

iftop -i br-wan -m 30M

nft -s list ruleset|less
