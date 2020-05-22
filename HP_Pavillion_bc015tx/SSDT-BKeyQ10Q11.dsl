// BrightKey for HP Pavillion bc-015tx
//
// If you want to modify for your model, please visit 
// https://github.com/daliansky/OC-little/tree/master/14-%e4%ba%ae%e5%ba%a6%e5%bf%ab%e6%8d%b7%e9%94%ae
// and follow the steps :)
//
// Rename in Opencore or Clover ACPI section
// [BKey]_Q10 to XQ10
// Find:     5F513130 00
// Replace:  58513130 00
//
// [BKey]_Q11 to XQ11
// Find:     5F513131 00
// Replace:  58513131 00
DefinitionBlock("", "SSDT", 2, "ERIC", "BrightFN", 0)
{
    External(_SB.PCI0.LPCB.PS2K, DeviceObj)
    External(_SB.PCI0.LPCB.EC0, DeviceObj)
    External(_SB.PCI0.LPCB.EC0.XQ10, MethodObj)
    External(_SB.PCI0.LPCB.EC0.XQ11, MethodObj)
    
    Scope (_SB.PCI0.LPCB.EC0)
    {
        Method (_Q10, 0, NotSerialized)//down
        {
            If (_OSI ("Darwin"))
            {
                Notify(\_SB.PCI0.LPCB.PS2K, 0x0405)
                Notify(\_SB.PCI0.LPCB.PS2K, 0x20)
            }
            Else
            {
                \_SB.PCI0.LPCB.EC0.XQ10()
            }
        }
    
        Method (_Q11, 0, NotSerialized)//up
        {
            If (_OSI ("Darwin"))
            {
                Notify(\_SB.PCI0.LPCB.PS2K, 0x0406)
                Notify(\_SB.PCI0.LPCB.PS2K, 0x10)
            }
            Else
            {
                \_SB.PCI0.LPCB.EC0.XQ11()
            }
        }
    }
}