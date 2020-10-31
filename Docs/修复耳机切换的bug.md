# 修复耳机孔、静音键LED

## bug 表现

对于国行有麦耳机（OMTP标准），在 Windows 下使用时发声正常，而在 macOS 下则出现发声沉闷，需要按住耳机中间按钮才能正常使用的情况。

根据 Windows 表现可推断该声卡具有切换耳机引脚定义的功能，使用 ALCPlugFix 成功修复了此 bug



## 修复方法

见[此处](../ALCPlugFix)

## 原理

使用 alc-verb 向 `IOHDADodecDevice` 发送 SET_PIN_WIDGET_CONTROL 命令，将 0x19 节点的 Pin-ctls 设置为 0x24，即可让声音正常。

此外还误打误撞发现 0x1b 节点的 Pin-ctls 若是设置为 0x1 则静音键LED亮起，设置为 0x0 则熄灭，故通过监听系统静音事件的方式，当系统进入静音状态时将 0x1b 节点设为 0x1，解除静音状态时设为 0x0。
