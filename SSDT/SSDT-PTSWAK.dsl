// Overriding _PTS and _WAK
// [PTSWAK]_PTS to ZPTS(1,N)
// Find:     5F50545301
// Replace:  5A50545301
//
// [PTSWAK]_WAK to ZWAK(1,S)
// Find:     5F57414B09
// Replace:  5A57414B09
//
DefinitionBlock("", "SSDT", 2, "OCLT", "PTSWAK", 0)
{
    External(ZPTS, MethodObj)
    External(ZWAK, MethodObj)
    External(EXT1, MethodObj)
    External(EXT2, MethodObj)
    External(EXT3, MethodObj)
    External(EXT4, MethodObj)
    External(DGPU._ON, MethodObj)
    External(DGPU._OFF, MethodObj)
    External(RMDT.P2, MethodObj)
    External (_SB_.PCI0.XHC_.PMEE, FieldUnitObj)



    Scope (_SB)
    {
        Device (PCI9)
        {
            Name (_ADR, Zero)
            Name (FNOK, Zero)
            Name (MODE, Zero)
            //
            Name (TPTS, Zero)
            Name (TWAK, Zero)
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
    
    Method (_PTS, 1, NotSerialized)
    {
        If (_OSI ("Darwin"))
        {
            \_SB.PCI9.TPTS = Arg0
            \RMDT.P2 ("RMDT: _PTS-Arg0=", \_SB.PCI9.TPTS)
            
            if(\_SB.PCI9.FNOK ==1)
            {
                Arg0 = 3
            }
            
            If (CondRefOf (\DGPU._ON))
            {
                \DGPU._ON ()
            }
            
            If (CondRefOf(EXT1))
            {
                EXT1(Arg0)
            }
            If (CondRefOf(EXT2))
            {
                EXT2(Arg0)
            }
            If ((0x05 == Arg0))    // Fix shutdown
            {
                \_SB.PCI0.XHC.PMEE = Zero
            }
        }

        ZPTS(Arg0)
    }
    
    Method (_WAK, 1, Serialized)
    {   
        If (_OSI ("Darwin"))
        {
            \_SB.PCI9.TWAK = Arg0
            \RMDT.P2 ("RMDT: _WAK-Arg0=", \_SB.PCI9.TWAK)

            if(\_SB.PCI9.FNOK ==1)
            {
                \_SB.PCI9.FNOK =0
                Arg0 = 3
            }
        
            If (CondRefOf (\DGPU._OFF))
            {
                \DGPU._OFF ()
            }
            
            If (CondRefOf(EXT3))
            {
                EXT3(Arg0)
            }
            If (CondRefOf(EXT4))
            {
                EXT4(Arg0)
            }
        }

        Local0 = ZWAK(Arg0)
        Return (Local0)
    }
}
//EOF