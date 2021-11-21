根据[这篇文章](http://www.tonymacx86.com/el-capitan-laptop-support/185808-alc668-no-sound-after-reboot-windows-10-a.html)

> The Realtek Driver in Windows will do something with the HDA COEF and make it wrong(don't know why). After reboot from windows to other OS(Linux, OS X), due to the wrong COEF, the speaker has no sound.
> The correct COEF for 0x07 register is 0x0f80, but the Realtek Driver will change it to 0x2f80.

也就是说，Windows 下的 Realtek 驱动有问题，0x07 寄存器的正确的 COEF 值应该是 0x0f80，而该驱动将这个值设为了 0x2f80，于是导致 Windows 热重启到 macOS 或是 Linux 下扬声器无声。

解决方法有两个，我只讲最简单的那个：
**卸载 Realtek 声卡驱动，切换为 Windows 自带的 HDA 驱动**

另一个方法是用 Codec Commander 来重设寄存器的值，不推荐此方法，在此不多引申了，感兴趣的朋友可以去原帖看看。

参考：
[Tonymacx86.com - Sound loss after reboot back from Windows](https://www.tonymacx86.com/threads/sound-loss-after-reboot-back-from-windows.264988/)
[Tonymacx86.com - [solved] No audio after reboot from Windows (AppleHDA w/ALC 668)
](https://www.tonymacx86.com/threads/solved-no-audio-after-reboot-from-windows-applehda-w-alc-668.187624/)