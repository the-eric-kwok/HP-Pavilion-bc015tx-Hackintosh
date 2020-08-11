# 修复耳机切换bug

## bug 表现

对于国行有麦耳机（黑色圈圈），在 Windows 下使用时发声正常，而在 macOS 下则出现发声沉闷，需要按住耳机中间按钮才能正常使用的情况。

根据 Windows 表现可推断具有切换耳机引脚定义的功能，尝试使用 ALCPlugFix 配合 CodecCommander + AppleALC 发现成功修复了此 bug



## 修复方法

1. 将 CodecCommander.kext 放到 kexts 中并修改配置，保证其加载，并且重启使其生效

2. 按 ⌘空格 组合键调出 Spotlight，搜索“终端”

3. 接着输入 `cd` ，后面跟一个空格

4. 将 ALCPlugFix 文件夹拖入终端

5. 按下回车

6. 然后输入

   ```
   ./install.sh
   ```

7. 重启