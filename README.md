# project liftium ios 16 for joyeuse

> **⚠️ WARNING / ПРЕДУПРЕЖДЕНИЕ**
>
> **EN:** Experimental and unofficial port of iOS 16.7.16 to Redmi Note 9 Pro (`joyeuse`). Use at your own risk; the author assumes no responsibility for hardware damage or data loss.
>
> **RU:** Экспериментальный неофициальный порт iOS 16.7.16 для Redmi Note 9 Pro (`joyeuse`). Используйте на свой страх и риск; автор не несет ответственности за повреждения устройства или потерю данных.

Forked from [maxexcloo/ios-joyeuse](https://github.com), based on [olaffx/ios-miatoll](https://github.com) and [ios-sweet](https://github.com).

---

## Status

**Boots into iOS SpringBoard with working touch, GPU acceleration (Metal-to-Vulkan), USB networking, and Sileo.**

* **Boot & Root:** Boots from dedicated `iosroot` partition (`/dev/block/sda19`); `PosterBoard` disabled to prevent restart loops.
* **Display & Touch:** Native 1080×2400 resolution and FocalTech FT8756 touch; sleep/wake requires `sweetbacklight=1`.
* **GPU & Rendering:** Hardware-accelerated via `SweetMetal2` + Turnip (Adreno 618) running at 50–60 FPS.
* **Jailbreak & Apps:** Procursus bootstrap and **Sileo** operational alongside stock apps.
* **Networking:** USB Ethernet (`en0` / `192.168.7.2`) functional; WLAN and SSH configuration in progress.
* **Pending Hardware:** Cellular, Bluetooth, Camera, Audio, and battery telemetry (static 100%) are not yet functional.

---

## Quick Reference & Workflow

* **Partition Layout:** Uses a dedicated case-sensitive HFS+ `iosroot` partition (`/dev/block/sda19`) to preserve Android dual-boot capabilities.
* **Build Tools:** Requires Python (Mise), LLVM toolchain, and specific device tree/firmware inputs placed locally in `fw/` and `ipsw/`.
* **Flashing:** 
  ```sh
  adb push out/ios16-root.img /dev/block/sda19
  fastboot boot out/shim-boot.img
  ```

*Полную техническую документацию, список команд сборки, параметры командной строки ядра и сведения об исходном коде смотрите в оригинальном репозитории и файле разметки.*
