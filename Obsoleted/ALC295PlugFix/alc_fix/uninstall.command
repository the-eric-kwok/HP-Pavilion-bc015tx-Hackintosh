#!/bin/bash

set -e

echo "Uninstalling ALCPlugFix.  Root user is required."

# detect if SIP disabled
sipstatus=$(csrutil status)
if [[ $sipstatus =~ 'enable' ]]; then
    echo "SIP is enabled, please consider disable it by setting"
    echo "csr-active-config to 7F000000 (DATA) and then reboot"
    echo "or running csrutil disable in terminal under recovery mode."
    exit 1
elif [[ $sipstatus =~ 'unknown' ]]; then
    echo "SIP status is unknown, please consider disable it by setting"
    echo "csr-active-config to 7F000000 (DATA) and then reboot"
    echo "or running csrutil disable in terminal under recovery mode."
    exit 1
fi

# check if the root filesystem is writeable (starting with macOS 10.15 Catalina, the root filesystem is read-only by default)
if sudo test ! -w "/"; then
    echo "Root filesystem is not writeable.  Remounting as read-write and restarting Finder."
    sudo mount -uw /
    sudo killall Finder
fi

echo "Removing files..."
sudo rm -v /usr/bin/ALCPlugFix
sudo rm -v /usr/bin/alc-verb
sudo launchctl unload -w /Library/LaunchDaemons/good.win.ALCPlugFix.plist
sudo launchctl remove good.win.ALCPlugFix
sudo rm -v /Library/LaunchDaemons/good.win.ALCPlugFix.plist


echo "Done!"
exit 0
