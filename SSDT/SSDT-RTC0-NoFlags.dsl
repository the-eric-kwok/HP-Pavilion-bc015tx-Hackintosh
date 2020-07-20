// This should fix the 'suddently poweroff before booting' problem
DefinitionBlock ("", "SSDT", 2, "OCLT", "RTCfix", 0)
{
    External(_SB.PCI0.LPCB, DeviceObj)

    // disable RTC at macOS
    External(_SB.PCI0.LPCB.RTC, DeviceObj)
    Scope (_SB.PCI0.LPCB.RTC)
    {
        Method (_STA, 0, NotSerialized)
        {
            If (_OSI ("Darwin"))
            {
                Return (Zero)
            }
            Else
            {
                Return (0x0F)
            }
        }
    }
    
    //Fake RTC0
    Scope (_SB.PCI0.LPCB)
    {
        Device (RTC0)
        {
            Name (_HID, EisaId ("PNP0B00")) 
            Name (_CRS, ResourceTemplate () 
            {
                IO (Decode16,
                    0x0070, 
                    0x0070,
                    0x01,
                    0x08,
                    )
            })
            
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }
    }
}
//EOF