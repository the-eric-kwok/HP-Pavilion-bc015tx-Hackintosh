# 电池电量补丁制作过程（其他补丁同理）
## 参考资料（必看）：
[ASL 语言基础](https://github.com/daliansky/OC-little/tree/master/00-总述/00-1-ASL语法基础)

[电池热补丁教程](https://xstar-dev.github.io/hackintosh_advanced/Guide_For_Battery_Hotpatch.html)

[更全面的ASL编程语言语法书](http://reader.epubee.com/books/mobile/94/94e6b6332e45c4c4b837e5067b0488b8/text00007.html)

以上三个页面建议打开多个标签页与本教程互相参考

## 需要准备的软件
[MaciASL](https://github.com/acidanthera/MaciASL/releases)

[Hackintool](https://github.com/headkaze/Hackintool/releases)

[Hex Fiend(App Store)](https://apps.apple.com/us/app/hex-fiend/id1342896380?mt=12) 或 [Hex Fiend(官网)](https://ridiculousfish.com/hexfiend/)

## 0x00 新建DSL文件
![](https://upload-images.jianshu.io/upload_images/3375171-5c08ea16279472b7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

保存并且命名为SSDT-BATT.dsl

## 0x01 反编译原来的 DSDT
参考[https://jcstaff.club/2019/DSDT-SSDT-battery](https://jcstaff.club/2019/DSDT-SSDT-battery)的提取和反编译两个小节来进行提取，不要用MaciASL来提取，因为MaciASL提取到的DSDT会受到Clover/OC的二进制重命名影响，用Clover提取到的是最好的原厂DSDT。

将 DSDT.aml 和 DSDT.dsl 都复制到桌面，在我们要确定如何做二进制更名时需要用到原本的aml文件。

## 0x02 搜索EC
在DSDT.dsl中搜索「PNP0C09」来找到你的EC，然后再从EC之中寻找所有的Field

... 表示省略了部分代码，下同

```
OperationRegion (ERAM, EmbeddedControl, Zero, 0xFF)
Field (ERAM, ByteAcc, Lock, Preserve)
{
        SMPR,   8, 
        SMST,   8, 
        SMAD,   8, 
        SMCM,   8, 
        SMD0,   256,  // <---------
        BCNT,   8, 
        SMAA,   8, 

        ...

        Offset (0x82), 
        MBST,   8, 
        MCUR,   16,   // <---------
        MBRM,   16,   // <---------
        MBCV,   16,   // <---------
        FGM1,   8, 
        FGM2,   8, 
        FGM3,   8, 
        Offset (0x8D),       

        ...

}

...

Field (ERAM, ByteAcc, NoLock, Preserve)
{
        Offset (0x04), 
        SMW0,   16  // <---------
}

Field (ERAM, ByteAcc, NoLock, Preserve)
{
        Offset (0x04), 
        SMB0,   8
}

Field (ERAM, ByteAcc, NoLock, Preserve)
{
        Offset (0x04), 
        FLD0,   64  // <---------
}

Field (ERAM, ByteAcc, NoLock, Preserve)
{
        Offset (0x04), 
        FLD1,   128  // <---------
}

Field (ERAM, ByteAcc, NoLock, Preserve)
{
        Offset (0x04), 
        FLD2,   192  // <---------
}

Field (ERAM, ByteAcc, NoLock, Preserve)
{
        Offset (0x04), 
        FLD3,   256  // <---------
}
```

像这样，把逗号后面数字大于8的变量和他们的Offset记录下来。

Offset怎么计算呢？

我们先看`OperationRegion (ERAM, EmbeddedControl, Zero, 0xFF)`这一句，括号里面第一个参数是区域名`ERAM`。

接着我们发现所有的Field里面的第一个参数也都是`ERAM`，可以确定它们是对同一个内存区域进行操作的，这一块内存区域名为 ERAM。

你的DSDT不一定都是 ERAM，如果出现了其他名字的 Field，请寻找对应的 OperationRegion 来确定它的类型和偏移量

`OperationRegion (ERAM, EmbeddedControl, Zero, 0xFF)`的第二个参数是`EmbeddedControl`，这个是操作空间类型，我的是 EmbeddedControl，而有的主板厂商会选择将EC数据映射到内存中，此时类型为 SystemMemory，且第三个参数通常不为零。

第三个参数是`Zero`，在ASL中 Zero 和 0 等效。此处参数为操作空间的偏移量，也就是Offset，**如果不为零的话我们也要把这个参数记录下来**。

第四个参数是`0xFF`，为操作空间的最大大小，此处为 0xFF Byte，化成十进制就是255个字节，不重要。

ok，现在我们知道我们只有一个操作区 ERAM，偏移量为0。

我们从头开始看
```
{
        SMPR,   8, 
        SMST,   8, 
        SMAD,   8, 
        SMCM,   8, 
        SMD0,   256,  // <---------
        BCNT,   8, 
        SMAA,   8, 
```
前面的 SMPR 是变量名，其类型为FieldUnitObj，后面的 8 是长度，单位为 bit。

8 bit，也就是 1 byte。

因此我们可以确定到第一个箭头指向的变量`SMD0`的偏移量是 (8+8+8+8)/8=4 byte

在SSDT-BATT.dsl的注释中记下来，`// 256bit: SMD0 (0x04)`

接着到第二段
```
        Offset (0x82), 
        MBST,   8, 
        MCUR,   16,   // <---------
        MBRM,   16,   // <---------
        MBCV,   16,   // <---------
```
此处难点为对 Offset(0x82) 的理解，不是空开0x82个字节的意思，而是将MBST对齐到0x82这个整数位上，所以我们可以直接得到MBST的偏移量为0x82，故`MCUR`的偏移量为0x83，类推得到 MBRM: 0x85，MBCV: 0x87

同样地，在注释中记下来`// 16bit: MCUR(0x83), MBRM(0x85), MBCV(0x87)`

第三段
```
Field (ERAM, ByteAcc, NoLock, Preserve)
{
        Offset (0x04), 
        SMW0,   16  // <---------
}
```
同理可得 `// 16bit: SMW0(0x04)`

以同样的方法将所有的 Field 中所有的大于 8 bit 的变量都记录下来，我们的第一节就完成了！

PS：之所以要将大于 8 bit 的变量记录下来是因为macOS不支持读取大于 8 bit 的变量，所以我们将在接下来的几节中将它们拆开为 8 bit 的大小。

## 0x03 介绍一下要用到的方法

所有的dsl都需要从一个 DefinitionBlock 中开始，我们也不例外。将这一段代码复制到你的dsl中

```
DefinitionBlock ("", "SSDT", 2, "ERIC", "BATT", 0) {

}
```

其中 ERIC 可以改成你的英文名，如果超过6个字符就缩写一下。毕竟是你自己编写的热补丁，著作权还是得有的嘛 XD

接着我们将这一段粘贴到大括号的内部**（删除所有中文注释！！）**

```
Method (B1B2, 2, NotSerialized)
{
    Return ((Arg0 | (Arg1 << 0x08)))
}
Method (B1B4, 4, NotSerialized)
{
    Local0 = (Arg2 | (Arg3 << 0x08))
    Local0 = (Arg1 | (Local0 << 0x08))
    Local0 = (Arg0 | (Local0 << 0x08))
    Return (Local0)
}
Method (W16B, 3, NotSerialized)
{
    Arg0 = Arg2
    Arg1 = (Arg2 >> 0x08)
}

Method (RE1B, 1, NotSerialized)
{
    OperationRegion (ERM2, EmbeddedControl, Arg0, One) // 作用域为 EmbeddedControl，Arg0 定义起始偏移量
    Field (ERM2, ByteAcc, NoLock, Preserve)
    {
        BYTE,   8 // 指定一个 8 位寄存器映射对应区域数据
    }

    Return (BYTE) // 返回结果
}
Method (RECB, 2, Serialized)
{
    Arg1 = ((Arg1 + 0x07) >> 0x03) // 计算 Arg1 除 8 并向上取整，位移运算更快
    Name (TEMP, Buffer (Arg1){}) // 初始化作为返回值的 Buffer
    Arg1 += Arg0 // 加上偏移量，即循环终止值
    Local0 = Zero // 定义 Buffer 索引为 0
    While ((Arg0 < Arg1)) // 进行循环，循环次数为初次计算的 Arg1，自行理解
    {
        TEMP [Local0] = RE1B (Arg0) // 调用 RE1B 依次返回 8 位数据
        Arg0++ // 偏移量自增
        Local0++ // 索引自增
    }

    Return (TEMP) // 返回最终结果
}

Method (WE1B, 2, NotSerialized)
{
    OperationRegion (ERM2, EmbeddedControl, Arg0, One) // EmbeddedControl 为 EC 作用域，Arg0 定义起始偏移量
    Field (ERM2, ByteAcc, NoLock, Preserve)
    {
        BYTE,   8 // 指定一个 8 位寄存器映射对应区域数据
    }

    BYTE = Arg1 // 将 Arg1 通过寄存器间接写入对应区域
}
Method (WECB, 3, Serialized)
{
    Arg1 = ((Arg1 + 0x07) >> 0x03) // 计算 Arg1 除 8 并向上取整，位移运算更快
    Name (TEMP, Buffer (Arg1){}) // 初始化作为写入值的 Buffer
    TEMP = Arg2 // 将被写入的数据或对象赋值给 TEMP
    Arg1 += Arg0 // 加上偏移量，即循环终止值
    Local0 = Zero // 定义 Buffer 索引为 0
    While ((Arg0 < Arg1)) // 进行循环，循环次数为初次计算的 Arg1，自行理解
    {
        WE1B (Arg0, DerefOf (TEMP [Local0])) // 调用 WE1B 依次写入 8 位数据
        Arg0++ // 偏移量自增
        Local0++ // 索引自增
    }
}
```

这一段是我们将会调用到的方法

`Method (B1B2, 2, NotSerialized)`是将两个Byte拼成一个Word的方法，如果你有编程基础你可以从源代码中看出来这一点。用于读取，传入两个Byte的参数，返回一个Word。

`Method (B1B4, 4, NotSerialized)`是将四个Byte拼成一个DWord的方法。调用时传入四个Byte的参数，返回一个DWord。

`Method (W16B, 3, NotSerialized)`是将一个Word拆开成两个Byte的方法。在使用时需要先初始化两个Local变量，然后 `W16B (Local0, Local1, Arg0)`。它会将Arg0拆分后放入Local0和Local1中。无返回值。

如

```
Local0 = 0
Local1 = 0
W16B(Local0, Local1, 0x3344)
```

执行后Local0 = 0x44，Local1 = 0x33

`Method (RECB, 2, Serialized)`是从内存区域中逐字节读取的方法。调用时传入两个参数，第一个参数为偏移量Offset，第二个参数为长度（bit），返回一个Byte数组。

`Method (WECB, 3, Serialized)`是将数据逐字节写回内存的方法。调用时传入三个参数，第一个参数是偏移量Offset，第二个参数是长度（bit），第三个参数是要写入的数据变量。无返回值。

## 0x04 拆分变量

还记得我们刚刚找出来的变量吗？

```
// 16bit:  BADC(0x70), BFCC(0x72), MCUR(0x83), MBRM(0x85), MBCV(0x87), SMW0(0x04)
// 64bit:  FLD0(0x04)
// 128bit: FLD1(0x04)
// 192bit: FLD2(0x04)
// 256bit: SMD0(0x04), FLD3(0x04)
```

将16bit的拆开为两个8bit的

比如 BADC -> ADC0, ADC1

按照这样的模式修改原文

先寻找原文，确定其作用域

![](https://upload-images.jianshu.io/upload_images/3375171-3108864bd773b956.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

如图可知，其作用域为Scope (\_SB.PCI0.LPCB.EC0)，故形成了这样的结构

```
Scope (\_SB.PCI0.LPCB.EC0) {
    OperationRegion(ERM0, EmbeddedControl, 0, 0xFF)
    Field(ERM0, ByteAcc, Lock, Preserve) {
        Offset(0x72),
        BFC0, 8,    // BFCC
        BFC1, 8,
        Offset(0x83),
        MCU0, 8,    // MCUR
        MCU1, 8,
        MBR0, 8,    // MBRM
        MBR1, 8,
        MBC0, 8,    // MBCV
        MBC1, 8
    }
    Field(ERM0, ByteAcc, NoLock, Preserve) {
        Offset (0x04)
        MW00, 8,    // SMW0
        MW01, 8
    }
}
```

此处由于BADC未被使用，所以不需要拆分。其他的将原文复制过来并且拆分，尤其要注意Field是Lock还是NoLock，如果搞错这个可能会产生未知的后果。

## 0x05 寻找需要更改的方法

```
// 16bit:  BADC(0x70), BFCC(0x72), MCUR(0x83), MBRM(0x85), MBCV(0x87), SMW0(0x04)
// 64bit:  FLD0(0x04)
// 128bit: FLD1(0x04)
// 192bit: FLD2(0x04)
// 256bit: SMD0(0x04), FLD3(0x04)
```

在MaciASL中按下⌘F组合键对每个变量名进行搜索，若只有声明没有调用则可以忽略，否则**将原方法复制粘贴到SSDT-BATT.dsl中**。
这里给出一个简单的例子

```
Method (UPBI, 0, NotSerialized)
{
    Store (^^PCI0.LPCB.EC0.BFCC, Local5)
    If (LAnd (Local5, LNot (And (Local5, 0x8000))))
    {
        ShiftRight (Local5, 0x05, Local5)
        ShiftLeft (Local5, 0x05, Local5)
        Store (Local5, Index (PBIF, One))
        Store (Local5, Index (PBIF, 0x02))
        Divide (Local5, 0x64, , Local2)
        Add (Local2, One, Local2)
        Multiply (Local2, 0x0C, Local4)
        Add (Local4, 0x02, Index (PBIF, 0x05))
        Multiply (Local2, 0x07, Local4)
        Add (Local4, 0x02, Index (PBIF, 0x06))
        Multiply (Local2, 0x0A, Local4)
        Add (Local4, 0x02, FABL)
    }
...
}
```

根据路径树确定此方法的Scope为`\_SB.BAT0`

![](https://upload-images.jianshu.io/upload_images/3375171-493858a3686d7393.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

将Scope添加上

```
Scope(\_SB.BAT0)
{  
    Method (UPBI, 0, NotSerialized)
    {
        Store (^^PCI0.LPCB.EC0.BFCC, Local5)
        If (LAnd (Local5, LNot (And (Local5, 0x8000))))
        {
            ShiftRight (Local5, 0x05, Local5)
            ShiftLeft (Local5, 0x05, Local5)
            Store (Local5, Index (PBIF, One))
            Store (Local5, Index (PBIF, 0x02))
            Divide (Local5, 0x64, , Local2)
            Add (Local2, One, Local2)
            Multiply (Local2, 0x0C, Local4)
            Add (Local4, 0x02, Index (PBIF, 0x05))
            Multiply (Local2, 0x07, Local4)
            Add (Local4, 0x02, Index (PBIF, 0x06))
            Multiply (Local2, 0x0A, Local4)
            Add (Local4, 0x02, FABL)
        }
}
```

我们需要修改的是这一句

```
Store (^^PCI0.LPCB.EC0.BFCC, Local5)
```

这是一句赋值语句，作用是将BFCC赋值给Local5

我们可以改成

```
Local5 = B1B2(^^PCI0.LPCB.EC0.BFC0, ^^PCI0.LPCB.EC0.BFC1)
```

其中`^^`是指代路径树之中上上层的节点，`^`则是指带的上层节点也就是父节点。

而若是超过16bit的变量则需要用WECB()和RECB()两个方法来读取或写入。

同样地，我给出一个例子
```
...
                        If (LLess (Local3, 0x09))
                        {
                            Store (FLD0, Local2)
                        }
...
```

我们可以修改为

```
...
                        If (LLess (Local3, 0x09))
                        {
                            //Store (FLD0, Local2)
                            Local2 = RECB(0x04, 64)    // 64bit:  FLD0(0x04)
                        }
...
```

**注意要放在对应的Scope里面！并且要将原方法完整地复制下来再做修改！**

## 0x06 添加操作系统判断

进行操作系统判断的语句如下

```
If (_OSI("Darwin"))     // If OS match macOS
{

}
Else
{
    // 调用原方法
}
```

其原理是调用_OSI()这个预置方法，若传入的字符串与操作系统内核名相匹配则返回1，If语句内容被执行。

字符串列表如下

|  操作系统   | 字符串  |
|  ----  | ----  |
| macOS  | "Darwin" |
| Linux(包括基于 Linux 内核的操作系统)  | "Linux" |
| FreeBSD | "FreeBSD" |
| Windows | "Windows 20XX" |

见[_osi--operating-system-interfaces-操作系统接口](https://github.com/daliansky/OC-little/tree/master/00-总述/00-1-ASL语法基础#_osi--operating-system-interfaces-操作系统接口)

举个例子，假设我们的原方法为（顺便一提，根据[惠普笔记本-acel-设备禁止](https://xstar-dev.github.io/hackintosh_advanced/Guide_For_Battery_Hotpatch.html#惠普笔记本-acel-设备禁止)这一节，我们需要将下面列出来的这个设备禁用掉，我就顺便拿来举例了）

```
Device (ACEL)
{
    Name (_HID, EisaId ("HPQ6007"))  // _HID: Hardware ID
...
    Method (_STA, 0, NotSerialized)  // _STA: Status
    {
        If (LEqual (^^LPCB.EC0.ECOK, One))
        {
            If (LEqual (DVPN, 0xFF))
            {
                Store (0x0F, Local0)
                Store (^^LPCB.EC0.SMRD (0xC7, 0x50, 0x0F, RefOf (Local1)), Local2)
                If (LOr (LNotEqual (Local1, 0x33), LNotEqual (Local2, Zero)))
                {
                    Store (Zero, Local0
                }
                Store (Local0, DVPN)
            }
        }
        Return (DVPN)
    }
...
}
```

我们可以将原来的_STA()方法重命名为XSTA()，然后用我们自己写的方法代替它。

```
    Scope(\_SB.PCI0.ACEL) {
        Method (_STA, 0, NotSerialized) {
            If (_OSI("Darwin")) {
                Return (0)
            }
            Else {
                Return(XSTA())
            }
        }
    }
```

这一个方法的意思是：如果操作系统为macOS，则返回0（禁用），否则调用原方法（XSTA）。如果是无返回值的方法则直接写方法路径名，不需要写Return()。

关于_STA方法返回值的详细内容请参阅[_sta-status-状态](https://github.com/daliansky/OC-little/tree/master/00-总述/00-1-ASL语法基础#_sta-status-状态)

## 0x07 二进制更名

这一节中我们要用到MaciASL、Hackintool和Hex Fiend配合来确定某个方法在二进制代码中如何进行替换。

首先我们用UPBI这个方法来举例。

MaciASL进入原厂DSDT.dsl中搜索UPBI

![](https://upload-images.jianshu.io/upload_images/3375171-19c9b64f729fe45a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

Hackintool 将 UPBI 转换为十六进制

![](https://upload-images.jianshu.io/upload_images/3375171-6dca1c73df4d10c3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

将此十六进制串复制下来在Hex Fiend中打开 DSDT.**aml** 搜索

如图，UPBI出现了两次

![](https://upload-images.jianshu.io/upload_images/3375171-f479d94e03fb9455.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

我们可以根据其上下文来找到对应的二进制代码

![](https://upload-images.jianshu.io/upload_images/3375171-b800648b478deb0b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

所以离这一段最近的UPBI即我们需要替换的内容。

![](https://upload-images.jianshu.io/upload_images/3375171-ed5041da94fc1ad3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

得到十六进制串：55504249 00

使用Hackintool发现要把UPBI替换成XPBI，只需要把55替换成58即可

![](https://upload-images.jianshu.io/upload_images/3375171-bfb3c6ce0baab2e7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

故完整的替换方法为：

```
[BATT]UPBI to XPBI
Find:    55504249 00
Replace: 55504249 00
```

其他的方法也这样替换。

需要注意的是，对于要替换的_SB.PCI0.ACEL._STA方法，由于_STA方法涉及的覆盖面太广，几乎每个设备都有自己的_STA方法，所以我们需要在Hex Fiend中获取更多的二进制代码，来唯一确定这个_STA方法。

如果你获取到的二进制代码在Hex Fiend中只能搜索到一处，正确的地方，那就可以放心地填入OpenCore/Clover，否则一定要获取更多的二进制代码。

最终我们获取到的替换方法为

```
[BATT]ACEL._STA to XSTA
Find:    055F5354 4100A040
Replace: 05585354 4100A040
```

## 0x08 处理External

External语句类似于C中的`#include`或者java中的`import`

如果你现在点击编译的话会出现这样的报错

![](https://upload-images.jianshu.io/upload_images/3375171-2ed2a558f20e7b84.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

我们需要加上External语句来告诉编译器我们引用的这些东西是在别的文件里面的

语句的格式大概是

```
External (_SB.PCI0.LPCB.EC0.XMRD, MethodObj)
```

第一个参数是路径名字，第二个参数是对象的类型，要根据原文的类型来做判断。

常见的类型有IntObj、FieldUnitObj、MutexObj、MethodObj、DeviceObj、PkgObj等，请参考[添加外部引用声明](https://xstar-dev.github.io/hackintosh_advanced/Guide_For_Battery_Hotpatch.html#添加外部引用声明)

## 0x09 [检查mutex是否已经置0](https://xstar-dev.github.io/hackintosh_advanced/Guide_For_Battery_Hotpatch.html#检查mutex是否已经置0)

请参照链接内教程完成。

## EOF

至此，我们的电池补丁终于完工了！

点击 File - Save As 另存为 aml 格式并且放到 OC/ACPI 文件夹中或者 Clover/ACPI/Patched 文件夹中，然后修改配置文件加载，并且将应该改名的方法全部改名，重启一下你就会看到，你的电池电量出现啦！

文笔拙劣，只能以自己的经验给出一些过程，本来想写得简单一点，但又害怕写得不明不白。如果有什么不懂的请一定要把开头给出的参考资料好好地读一遍，踩在巨人的肩膀上才能望得更远，感谢在黑苹果这条道路上辛勤开拓的前辈们，RehabMan、acidanthera、黑果小兵、XStar、Xjn、等等。

欢迎在评论区留言交流。

附件📎：[SSDT-BatteryFix.dsl](https://github.com/the-eric-kwok/HP-Pavillion-bc015tx-SSDT/blob/master/HP_Pavillion_bc015tx/SSDT-BatteryFix.dsl)

[OC-补丁库](https://github.com/daliansky/OC-little)
