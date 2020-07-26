# HP Pavillion bc015tx Hackintosh

| Part       | Info                                                         |
| ---------- | ------------------------------------------------------------ |
| Model      | HP Pavillion bc015tx                                         |
| CPU        | Intel Core i7-6700HQ                                         |
| Mem        | Hynix 8GB DDR4 2400 MHz                                      |
| SSD        | SAMSUNG MZNTY128HDHP-000H1 128GB                             |
| HDD        | HGST HTS721010A9E630 1TB                                     |
| IGPU       | Intel HD Graphics 530                                        |
| DGPU       | Nvidia GTX960M                                               |
| Sound Card | Realtek ALC295 (Layout ID = 28 or 77)                        |
| WIFI / BT  | <ul><li>Original: Intel AC7265</li><li>Replacement: DELL DW1820A (Pci14e4,43a3)</li></ul> |
| Ethernet   | RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller    |



## Not Working

1. Nvidia DGPU
2. HDMI output



## Working

1. Intel iGPU
2. Sound
3. USB
4. Ethernet
5. Wi-Fi (Works perfectly after replace with 1820A, Sidecar, Handoff, Airdrop is working as well. If you are using the original card, you can consider about [itlwm](https://github.com/OpenIntelWireless/itlwm) with [HeliPort](https://github.com/OpenIntelWireless/HeliPort), but the package loss is a pain in the ass. )
6. Bluetooth (Original card use [IntelBluetoothFirmware](https://github.com/OpenIntelWireless/IntelBluetoothFirmware)）
7. Battery percentage（SSDT-BatteryFix.dsl）
8. Trackpad partially working（PS2触控板对多指手势支持不好）
9. Sleep partially working
10. CPU power management
11. Brightness keys (SSDT-BKeyQ10Q11.dsl)
12. Media keys
13. Card reader (by Sinetek-rtsx.kext)
14. Switch between left Windows (now is ⌘) and Alt (now is ⌥ ). Right Alt remains as ⌘, so the `⌘Del` is more convincing (by SSDT-SwapCmdOpt.dsl)



## About 1820A

Without replacement of 1820A you **DONT NEED** these kexts:

- BrcmBluetoothInjector.kext
- BrcmFirmwareData.kext
- BrcmPatchRAM3.kext
- AirportBrcmFixup.kext



## BIOS Settings

Press F10 at boot time to enter BIOS, disable Intel SGX and Secure Boot.

![IMG_1673](/Volumes/Data/eric/Documents/SSDT相关/HP-Pavillion-bc015tx-Hackintosh/img/IMG_1673.jpeg)

![IMG_1674](/Volumes/Data/eric/Documents/SSDT相关/HP-Pavillion-bc015tx-Hackintosh/img/IMG_1674.jpeg)

![IMG_1675](/Volumes/Data/eric/Documents/SSDT相关/HP-Pavillion-bc015tx-Hackintosh/img/IMG_1675.jpeg)



## ⚠️Warning⚠️

Don't download kext inside kexts folder, you should download the latest version of them instead. 

You should compile the dsl file under SSDT before putting them to ACPI, using iASL or MaciASL or AIDA64 Enginear.

```
# in the terminal
iasl SSDT-xxx.dsl

# Windows will be like this
# C:\User\Someone\Downloads\iasl.exe SSDT=xxx.dsl
```

Update:

Added SSDT-aml. If you are not familiar with compile or you can't do that compile thing you could add some patch from SSDT-aml. **But you should hotpatch original DSDT according comments in the dsl !**



Needed SSDT：

- SSDT-EC-USBX
- SSDT-NDGP_OFF
- SSDT-PLUG-_PR.CPU0
- SSDT-PNLF-SKL_KBL
- SSDT-SBUS
- ~~SSDT-ALS0~~ Merged into SSDT-AddDev

Check [OC-Little](https://github.com/daliansky/OC-little/) for more patching guide



**BTW, SSDT-BATT and SSDT-Battery has the same function, they both patch for the battery percentage. Use ONE of them. **

**Set `csr-active-config` under OC-config.plist - NVRAM to `00000000` if you are fresh installing.**

## Links

[OpenCorePkg](https://github.com/acidanthera/OpenCorePkg/releases)

[Clover](https://github.com/CloverHackyColor/CloverBootloader/releases)

[OC-Little](https://github.com/daliansky/OC-little/)



## Catalog

[About 1820A](About 1820A.md)

[About Intel AC7265](About Intel AC7265.md)

[Patching USB with Hackintool](Patching USB with Hackintool.md)

[Fixing Suddenly Poweroff On BIOS Stage](Fixing Suddenly Poweroff On BIOS Stage.md)

