According to [this page](http://www.tonymacx86.com/el-capitan-laptop-support/185808-alc668-no-sound-after-reboot-windows-10-a.html).

> The Realtek Driver in Windows will do something with the HDA COEF and make it wrong(don't know why). After reboot from windows to other OS(Linux, OS X), due to the wrong COEF, the speaker has no sound.
> The correct COEF for 0x07 register is 0x0f80, but the Realtek Driver will change it to 0x2f80.

So there are 2 ways to fix this issue, here I will go through the simple one:
** remove Realtek Driver, and switch back to Windows HDA driver. **

The other method is reseting COEF with Codec Commander, check the original post for more info.

References:
[Tonymacx86.com - Sound loss after reboot back from Windows](https://www.tonymacx86.com/threads/sound-loss-after-reboot-back-from-windows.264988/)
[Tonymacx86.com - [solved] No audio after reboot from Windows (AppleHDA w/ALC 668)
](https://www.tonymacx86.com/threads/solved-no-audio-after-reboot-from-windows-applehda-w-alc-668.187624/)