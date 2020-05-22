// AirplaneButtonDebug
// Rename _Q15 to XQ15
// Find:    5F513135 00
// Replace: 58513135 00
DefinitionBlock("", "SSDT", 2, "ERIC", "BrightFN", 0)
{
    External(_SB.PCI0.LPCB.EC0, DeviceObj)
    External(_SB.PCI0.LPCB.PS2K, DeviceObj)
    External(_SB.PCI0.LPCB.EC0.XQ15, MethodObj)
    //
    External(RMDT.P2, MethodObj)
    External(_SB.PCI9.TPTS, IntObj)
    External(_SB.PCI9.TWAK, IntObj)
    //
    Scope (_SB.PCI0.LPCB.EC0)
    {
        Method (_Q15, 0, NotSerialized)
        {
            If (_OSI ("Darwin"))
            {
                //Debug...
                \RMDT.P2 ("ABCD-_PTS-Arg0=", \_SB.PCI9.TPTS)
                \RMDT.P2 ("ABCD-_WAK-Arg0=", \_SB.PCI9.TWAK)
                //Debug...end
                
                //Notify(\_SB.PCI0.LPCB.PS2K, 0x0405)
                //Notify(\_SB.PCI0.LPCB.PS2K, 0x20)
            }
            Else
            {
                \_SB.PCI0.LPCB.EC0.XQ15()
            }
        }
    }
}