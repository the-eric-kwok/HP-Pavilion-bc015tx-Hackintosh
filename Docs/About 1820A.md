# 关于 1820A

首先，如果你没有更换自己的网卡的话**不需要**以下kext：

- BrcmBluetoothInjector.kext
- BrcmFirmwareData.kext
- BrcmPatchRAM3.kext
- AirportBrcmFixup.kext



## 注意事项

AirportBrcmFixup.kext 是 WiFi 驱动，其余三个是蓝牙驱动。

一定要确保 BrcmBluetoothInjector.kext 是最先加载的，所以我推荐使用 OpenCore，可以控制加载顺序。如果 BrcmBluetoothInjector.kext 加载晚了会导致蓝牙不可用。

此外，这一套是为了 10.15 搭配使用的，如果你是 10.14 或者更老的版本，应该将 BrcmPatchRAM3.kext 换为 BrcmPatchRAM2.kext （建议从 [DW1820A/BCM94350ZAE/BCM94356ZEPA50DX插入的正确姿势](https://blog.daliansky.net/DW1820A_BCM94350ZAE-driver-inserts-the-correct-posture.html)文中的下载链接下载）



## Big Sur

Big Sur 中只有 AirPortBrcmNIC 这一个驱动，所以只能驱动以下几种型号

- Pci14e4,43ba
- Pci14e4,43a3
- Pci14e4,43a0

随航应该是默认可用的，所以下面的内容可以忽略了

参考[AirportBrcmFixup](https://github.com/acidanthera/AirportBrcmFixup)



## 随航

### 修复了

32002 错误

![5](img/5.png)

### 适用于：

下列三种型号的1820A

- Pci14e4,43ba
- Pci14e4,43a3
- Pci14e4,43a0

你可以在「系统信息」中查看网卡型号，如图所示即 Pci14e4,43a3

![](img/1.png)

### 参考资料：

[DW1820A/BCM94350ZAE/BCM94356ZEPA50DX插入的正确姿势](https://blog.daliansky.net/DW1820A_BCM94350ZAE-driver-inserts-the-correct-posture.html)

[AirportBrcmFixup 的 Github Page](https://github.com/acidanthera/AirportBrcmFixup)

### 教程：

首先参照上面的链接将网卡调试至可以正常使用的状态，此时打开【系统信息】- 软件 - 功能扩展，你应该会看到在AirPortBrcm4360中：

```
AirPortBrcm4360：


  版本：         14.0
  上次修改：      2020/1/10 下午2:30
  捆绑包标识符：   com.apple.driver.AirPort.Brcm4360
  已公正：        是
  已载入：        是...
```

在AirPortBrcmNIC中：

```
AirPortBrcmNIC：


  版本：         14.0
  上次修改：      2020/1/10 下午2:30
  捆绑包标识符：   com.apple.driver.AirPort.BrcmNIC
  已公正：        是
  已载入：        否...
```

我们启动OpenCore配置器，在**DeviceProperties**中，找到Wi-Fi相关的设备地址，删除它里面的compatible属性。接着进入**NVRAM**，选择 `7C436110-AB2A-4BBB-A880-FE41995C9F82` 这一项，右边的 **boot-args** 中增加一句 `brcmfx-driver=2 `

Clover的话是在**设备设置** - **属性**中，同样是找到Wi-Fi相关的设备地址，删除它里面的compatible属性，然后在“引导参数”中点+号增加一个条目，里面填上 `brcmfx-driver=2` 

这是让AirportBrcmFixup强制macOS载入AirPortBrcmNIC这个驱动，而不是AirPortBrcm4360
以下是AirportBrcmFixup说明书的原文

> brcmfx-driver=0|1|2|3: enables only one kext for loading, 0 - AirPortBrcmNIC-MFG, 1 - AirPortBrcm4360, 2 - AirPortBrcmNIC, 3 - AirPortBrcm4331, also can be injected via DSDT or Properties → DeviceProperties in bootloader

完成之后保存重启，再次打开【系统信息】- 软件 - 功能扩展，你应该会看到AirPortBrcmNIC中的已载入变成了“是”

```
AirPortBrcmNIC：


  版本：         14.0
  上次修改：      2020/1/10 下午2:30
  捆绑包标识符：   com.apple.driver.AirPort.BrcmNIC
  已公正：        是
  已载入：        是
```

好啦，这下你可以试试和iPad连一下随航了！

（按黑果小兵的教程来看，这个方法似乎也会启用对Apple Watch解锁的支持，我没有Apple Watch，不做测试啦）

