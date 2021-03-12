# [ALCPlugFix-Swift](https://github.com/black-dragon74/ALCPlugFix-Swift)

(c) 2020 black.dragon74 aka Nick

macOS daemon to send HD Audio commands (HDA Verbs) to an `IOHDACodecDevice` from user-sapce.

Check the homepage [here](https://github.com/black-dragon74/ALCPlugFix-Swift).



In this project, we use ALCPlugFix to send `SET_PIN_WIDGET_CONTROL` , and set pin widget of node `0x19` to `0x24`, so that the default audio input will switch to head phone mic. Also this will enable support for both OMTP and CTIA head phone. 

在本项目中，使用 ALCPlugFix 向声卡发送 `SET_PIN_WIDGET_CONTROL` 命令，在启动和插入耳机时将 `0x19 ` 节点的 Pin widget 设置为 `0x24`，以此将麦克风切换到耳机麦，同时能支持OMTP和CTIA两种标准的耳机，解决耳机无人声/声音含糊的问题。



## Installing 安装

Double click on `install.command` , input your password (password is not visible) and drag `sample.plist` into the console.

This script will install `ALCPlugFix-Swift` into `/usr/local/bin` , and `sample.plist` to `/etc/ALCPlugFix/config.plist`, and `com.black-dragon74.ALCPlugFix.plist` to `/Library/LaunchAgent`



双击 `install.command`，输入你的密码（盲输），然后把 `sample.plist` 拖到这个终端里。

此脚本将把 `ALCPlugFix-Swift` 安装到 `/usr/local/bin`，`sample.plist` 安装到 `/etc/ALCPlugFix/config.plist` ，`com.black-dragon74.ALCPlugFix.plist` 安装到 `/Library/LaunchAgent`



## Dependency 依赖

This fix requires AppleALC version 1.5.4+ or the patch of commit [61e2bbf](https://github.com/acidanthera/AppleALC/commit/61e2bbfe74bf1c12ebf770ed4a9776a04a7758f2) applied. 

此修复方法依赖于 v1.5.4 之后的 AppleALC。

