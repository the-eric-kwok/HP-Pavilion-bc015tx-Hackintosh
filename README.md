# HP Pavillion bc015tx Hackintosh

| 规格      | 详细信息                                                  |
| --------- | --------------------------------------------------------- |
| 电脑型号  | HP Pavillion bc015tx                                      |
| 处理器    | Intel Core i7-6700HQ                                      |
| 内存      | Hynix 8GB DDR4 2400 MHz                                   |
| 固态硬盘  | SAMSUNG MZNTY128HDHP-000H1 128GB                          |
| 机械硬盘  | HGST HTS721010A9E630 1TB                                  |
| 集成显卡  | Intel HD Graphics 530                                     |
| 独立显卡  | 无法驱动                                                  |
| 声卡      | Realtek ALC295                                            |
| WIFI / BT | DELL DW1820A (0A5C:6412)                                  |
| 有线网卡  | RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller |

## 无法驱动

1. 独立显卡
2. HDMI输出（HDMI走的独显，故无解）

## 正常功能

1. 核芯显卡
2. 声卡
3. USB 全部功能正常
4. 网卡（有线网卡正常，无线网卡更换为1820A后完美，可随航）
5. 电池电量（SSDT-BatteryFix.dsl）
6. 触摸板手势部分可用（PS2触控板对多指手势支持不好）
7. 睡眠基本正常
8. 变频正常
9. 支持原生亮度快捷键（SSDT-BKeyQ10Q11.dsl）
10. 支持原生多媒体控制键（自动支持了）
11. 支持读卡器（通过Sinetek-rtsx.kext）

## ⚠️警告⚠️

十分不建议直接下载kexts文件夹中的kext使用，你应该按照对应的kext名字进行搜索，并且使用最新版本的kext

SSDT中的dsl文件需要编译成aml文件再放到ACPI下注入