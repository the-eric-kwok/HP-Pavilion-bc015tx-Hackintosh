// Provide Methods for SSDT-PTSWAK.dsl to control Nvidia Graphics Card on/off
DefinitionBlock("", "SSDT", 2, "OCLT", "NDGP", 0)
{
    External(_SB.PCI0.PEG0._ON, MethodObj)
    External(_SB.PCI0.PEG0._OFF, MethodObj)
 
    //If (_OSI ("Darwin"))
    //{
        Device(DGPU)
        {
            Name(_HID, "DGPU1000")
            Method (_INI, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    _OFF()
                }
            }
            
            Method (_ON, 0, NotSerialized)
            {
                //path:
                If (CondRefOf (\_SB.PCI0.PEG0._ON))
                {
                    \_SB.PCI0.PEG0._ON()
                }
            }
            
            Method (_OFF, 0, NotSerialized)
            {
                //path:
                If (CondRefOf (\_SB.PCI0.PEG0._OFF))
                {
                    \_SB.PCI0.PEG0._OFF()
                }
            }
        }
    //}
}
//EOF