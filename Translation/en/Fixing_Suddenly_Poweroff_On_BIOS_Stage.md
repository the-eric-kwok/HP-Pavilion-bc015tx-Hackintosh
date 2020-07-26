# Fixing Suddenly Poweroff On BIOS Stage

## Issue

This issue appears after shutdown or reboot from macOS. We press power button, the machine starts to boot. If we press Esc now, there will be some text showing the machine detected out interrupt, but suddenly the machine power off, and then re-powered and boot normally. 



## How To Fix

You can just enable FixRTC in Clover, or using SSDT like what OpenCore users do.

The SSDT way:

Install [SSDT-HPET_RTC_TIMR-fix.dsl](https://github.com/daliansky/OC-little/tree/master/21-声卡IRQ补丁). 

Remember, referring to the original DSDT, we should replace HPAE with HPTE in this SSDT. 

See [the file after replacement](../../SSDT/SSDT-Fix-HPET_RTC_TIMR.dsl)





## [Warning](https://github.com/daliansky/OC-little/tree/master/21-声卡IRQ补丁#注意事项)

- This patch in incompatible with:
  
  - [SSDT-RTC_Y-AWAC_N](https://github.com/daliansky/OC-little/blob/master/03-二进制更名与预置变量/补丁库/SSDT-RTC_Y-AWAC_N.dsl)
  - [SSDT-AWAC](https://github.com/acidanthera/OpenCorePkg/blob/master/Docs/AcpiSamples/SSDT-AWAC.dsl)
  - [SSDT-RTC0](https://github.com/acidanthera/OpenCorePkg/blob/master/Docs/AcpiSamples/SSDT-RTC0.dsl) or [SSDT-RTC0](https://github.com/daliansky/OC-little/blob/master/02-仿冒设备/02-2-RTC0/SSDT-RTC0.dsl)
  - [SSDT-RTC0-NoFlags](https://github.com/daliansky/OC-little/blob/master/15-CMOS相关/15-1-CMOS重置补丁/SSDT-RTC0-NoFlags.dsl)
  
  or other patch that names like them
  
- `LPCB`, `HPE0`, `RTC0`, `TIM0` and `IPIC` should have the same ACPI path as they are in the original DSDT. 

  