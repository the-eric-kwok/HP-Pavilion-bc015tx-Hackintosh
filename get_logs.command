echo ' _                    _____           _     _               '
echo '| |                  / ____|         | |   | |              '
echo '| |     ___   __ _  | |  __ _ __ __ _| |__ | |__   ___ _ __ '
echo '| |    / _ \ / _` | | | |_ | `__/ _` |  _ \|  _ \ / _ \ `__|'
echo '| |___| (_) | (_| | | |__| | | | (_| | |_) | |_) |  __/ |   '
echo '|______\___/ \__, |  \_____|_|  \__,_|_.__/|_.__/ \___|_|   '
echo '              __/ |                                         '
echo '             |___/                      by: Eric Kwok       '
echo ''
echo ''

ACPI_LOG=~/Desktop/acpi.log
VOODOO_LOG=~/Desktop/voodoo.log
DMESG_LOG=~/Desktop/dmesg.log
ZIP_FILE=~/Desktop/log.zip

echo '请输入锁屏密码，为了安全，您的密码将被隐藏'
sudo true

echo '正在清理此前日志...'
if [ -f ${ZIP_FILE} ]; then
	rm ${ZIP_FILE}
fi
if [ -f ${ACPI_LOG} ]; then
	rm ${ACPI_LOG}
fi
if [ -f ${VOODOO_LOG} ]; then
	rm ${VOODOO_LOG}
fi
if [ -f ${DMESG_LOG} ]; then
	rm ${DMESG_LOG}
fi

echo '正在获取 ACPI 日志...' | tee ${ACPI_LOG}
echo '$ log show --last boot --style compact | grep -i acpi' >> ${ACPI_LOG}
log show --last boot --style compact | grep -i acpi >> ${ACPI_LOG}

echo '正在获取 Voodoo 日志...' | tee ${VOODOO_LOG}
echo '$ kextstat | grep -i voodoo' >> ${VOODOO_LOG}
kextstat | grep -i voodoo >> ${VOODOO_LOG}
echo '$ log show --last boot --style compact | grep -i voodoo' >> ${VOODOO_LOG}
log show --last boot --style compact | grep -i voodoo >> ${VOODOO_LOG}

echo '正在获取 dmesg 日志' | tee ${DMESG_LOG}
echo '$ sudo dmesg' >> ${DMESG_LOG}
sudo dmesg >> ${DMESG_LOG}


zip ${ZIP_FILE} ${ACPI_LOG} ${VOODOO_LOG} ${DMESG_LOG} 2>&1 > /dev/null

rm ${ACPI_LOG} ${VOODOO_LOG} ${DMESG_LOG}

echo '日志抓取完毕，请将桌面上的 log.zip 发送给我。'

open ~/Desktop
