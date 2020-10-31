# HP Pavillion bc015tx Hackintosh

Language:

- [简体中文](README.md)
- [English](Translation/en/README.md)



| 规格      | 详细信息                                                     |
| --------- | ------------------------------------------------------------ |
| 电脑型号  | HP Pavillion bc015tx                                         |
| 处理器    | Intel Core i7-6700HQ                                         |
| 内存      | Hynix 8GB DDR4 2400 MHz                                      |
| 固态硬盘  | SAMSUNG MZNTY128HDHP-000H1 128GB                             |
| 机械硬盘  | HGST HTS721010A9E630 1TB                                     |
| 集成显卡  | Intel HD Graphics 530                                        |
| 独立显卡  | Nvidia GTX960M                                               |
| 声卡      | Realtek ALC295 (Layout ID = 24)                          |
| WIFI / BT | <ul><li>原装: Intel AC7265</li><li>更换后: DELL DW1820A (Pci14e4,43a3)</li></ul> |
| 有线网卡  | RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller    |



## 无法驱动

1. 独立显卡
2. HDMI输出（HDMI走的独显，故无解）



## 正常功能

1. 核芯显卡
2. 声卡
3. USB 全部功能正常
4. 有线网卡
5. 无线网卡（更换为1820A后完美，可随航，原装卡(AC7265)可以考虑[itlwm](https://github.com/OpenIntelWireless/itlwm)配合[HeliPort](https://github.com/OpenIntelWireless/HeliPort)，但是性能还比较差，丢包严重）
6. 蓝牙（如果是原装卡用[IntelBluetoothFirmware](https://github.com/OpenIntelWireless/IntelBluetoothFirmware)）
7. 电池电量（SSDT-BatteryFix.dsl）
8. 触摸板手势可用（切换到VoodooRMI解决多指触控问题）
9. 睡眠基本正常
10. 变频正常
11. 支持原生亮度快捷键（BrightnessKey.kext）
12. 支持原生多媒体控制键（自动支持了）
13. 支持读卡器（通过Sinetek-rtsx.kext）
14. 交换了左侧的 Windows（现为⌘）和 Alt（现为⌥）键，右侧 Alt 依旧作为 ⌘ 键，方便使用删除文件快捷键（SSDT-SwapCmdOpt.dsl）



## 关于 1820A

如果你没有更换自己的网卡的话**不需要**以下kext：

- BrcmBluetoothInjector.kext
- BrcmFirmwareData.kext
- BrcmPatchRAM3.kext
- AirportBrcmFixup.kext



## BIOS设置

开机时按下 F10 进入 BIOS 设置，禁用 Intel SGX 和安全启动

![IMG_1673](img/IMG_1673.jpeg)

![IMG_1674](img/IMG_1674.jpeg)

![IMG_1675](/img/IMG_1675.jpeg)



## ⚠️警告⚠️

十分不建议直接下载kexts文件夹中的kext使用，你应该按照对应的kext名字进行搜索，并且使用最新版本的kext。

SSDT中的dsl文件需要用MaciASL或者AIDA64工程版或者iASL编译成aml文件再放到ACPI下注入

```
# 命令行中输入此命令
iasl SSDT-xxx.dsl

# Windows下可能是这样的
# C:\User\Someone\Downloads\iasl.exe SSDT=xxx.dsl
```

添加了SSDT-aml文件夹，如果不方便编译的可以先添加一些必备的SSDT，但是**一定要按照dsl文件中的注释进行二进制替换（即OC config ACPI中的Patch栏）！**

必备的SSDT：

- SSDT-EC-USBX
- SSDT-NDGP_OFF
- SSDT-PLUG-_PR.CPU0
- SSDT-PNLF-SKL_KBL
- SSDT-SBUS
- ~~SSDT-ALS0~~ 现在合并入 SSDT-AddDev 了

其他的SSDT多为完善功能用，其重要性并没有上面这些重要。建议先确保系统能进去了再一个个试着添加。

如果进不去系统，请参照[OC-Little](https://github.com/daliansky/OC-little/)对自己的SSDT进行调整。

我的SSDT很多都是照抄OC-Little库中的，所以OC-Little**一定要自己看了理解实践**，这样才能打造一个属于你的完美黑苹果！

**BTW，SSDT-BATT和SSDT-Battery功能重复，都是电池热补丁，不过一个是Pavillion 15 通用型补丁，一个是bc015tx专用的补丁，可以根据喜好选择编译使用**

**此外，安装时你应该将 OC-config.plist - NVRAM 下的`csr-active-config`设置为`00000000`**

## 链接

[OpenCorePkg](https://github.com/acidanthera/OpenCorePkg/releases)

[Clover](https://github.com/CloverHackyColor/CloverBootloader/releases)

[OC-Little](https://github.com/daliansky/OC-little/)



## 打赏

![donation](img/donate.png)



## 目录

[关于 1820A 网卡](Docs/About_1820A.md)

[关于原装 Intel AC7265 网卡](Docs/About_Intel_AC7265.md)

[使用 Hackintool 进行 USB 定制](Docs/使用Hackintool进行USB定制.md)

[从 VoodooPS2 迁移到 VoodooRMI](Docs/从VoodooPS2迁移到VoodooRMI.md)

[修复开机时的突然断电重启](Docs/修复开机时的突然断电重启.md)

[修复耳机切换的bug](Docs/修复耳机切换的bug.md)

