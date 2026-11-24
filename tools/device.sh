#!/bin/bash
# Device helpers. Raw reads/writes are restricted to the dedicated iosroot partition.
set -euo pipefail
REPO=$(cd "$(dirname "$0")/.." && pwd)

joyeuse_device() {
	local devices product
	devices=$(fastboot devices)
	[[ $(printf '%s\n' "$devices" | grep -c .) = 1 ]] || { echo "Need exactly one fastboot device." >&2; exit 1; }
	device=$(printf '%s\n' "$devices" | awk '{print $1}')
	product=$(fastboot -s "$device" getvar product 2>&1 | awk '$1 == "product:" {print $2}')
	[[ $product = joyeuse ]] || { echo "Not a joyeuse device: $product" >&2; exit 1; }
}

case ${1:-} in
status)
	adb devices -l || true
	fastboot devices || true
	;;
backup)
	dir=${2:?usage: device.sh backup DIR}
	mkdir -p "$(dirname "$dir")"; mkdir "$dir"
	dev=$(adb shell 'readlink -f /dev/block/by-name/iosroot 2>/dev/null' | tr -d '\r')
	[[ $dev == /dev/block/* ]] || { echo "iosroot not found; refusing other partitions" >&2; exit 1; }
	want=$(adb shell "blockdev --getsize64 '$dev'" | tr -d '\r')
	adb exec-out "dd if='$dev' 2>/dev/null" > "$dir/iosroot.img"
	got=$(stat -c %s "$dir/iosroot.img")
	[[ $got == "$want" ]] || { echo "iosroot read incomplete" >&2; exit 1; }
	sha256sum "$dir/iosroot.img" > "$dir/SHA256SUMS"
	;;
flash-root)
	img=${2:?usage: device.sh flash-root IMG}
	[[ -f $img ]] || { echo "no image: $img" >&2; exit 1; }
	case ${3:-iosroot} in iosroot) ;; userdata|boot|recovery) echo "Refusing target ${3}; only iosroot is permitted" >&2; exit 1;; *) echo "Target must be iosroot" >&2; exit 1;; esac
	joyeuse_device
	read -r -p "Type FLASH-IOSROOT to write only iosroot: " answer
	[[ $answer == FLASH-IOSROOT ]] || { echo cancelled >&2; exit 1; }
	fastboot -s "$device" -S 512M flash iosroot "$img"
	;;
boot)
	img=${2:?usage: device.sh boot IMG}
	joyeuse_device
	fastboot -s "$device" boot "$img"
	;;
pull-log)
	out=${2:?usage: device.sh pull-log FILE}
	"$REPO/tools/sweet-log-pull.sh" "$out"
	;;
*)
	echo "Usage: device.sh status|backup DIR|flash-root IMG [iosroot]|boot IMG|pull-log FILE" >&2
	exit 2
	;;
esac
