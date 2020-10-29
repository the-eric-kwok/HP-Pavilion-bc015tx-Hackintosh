#!/bin/bash

set -e

echo "Uninstalling ALCPlugFix.  Root user is required."
DIRNAME=$(dirname $0)

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

echo "Copying files..."
sudo cp -v ${DIRNAME}/ALCPlugFix /usr/bin
sudo chmod 755 /usr/bin/ALCPlugFix
sudo chown root:wheel /usr/bin/ALCPlugFix
sudo cp -v ${DIRNAME}/alc-verb /usr/bin
sudo chmod 755 /usr/bin/alc-verb
sudo chown root:wheel /usr/bin/alc-verb
sudo cp -v ${DIRNAME}/good.win.ALCPlugFix.plist /Library/LaunchDaemons/
sudo chmod 644 /Library/LaunchDaemons/good.win.ALCPlugFix.plist
sudo chown root:wheel /Library/LaunchDaemons/good.win.ALCPlugFix.plist

echo "Loading daemon..."
sudo launchctl load -w /Library/LaunchDaemons/good.win.ALCPlugFix.plist

echo "Done!"
exit 0
