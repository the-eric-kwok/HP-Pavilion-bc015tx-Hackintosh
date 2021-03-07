// Battery hotpatch for HP Pavillion bc-015tx
//
// How to make battery hotpatch: https://xstar-dev.github.io/hackintosh_advanced/Guide_For_Battery_Hotpatch.html
//
// Variable which has been patched: VarName(Offset)
// 16bit:  BADC(0x70), BFCC(0x72), MCUR(0x83), MBRM(0x85), MBCV(0x87), SMW0(0x04)
// 64bit:  FLD0(0x04)
// 128bit: FLD1(0x04)
// 192bit: FLD2(0x04)
// 256bit: SMD0(0x04), FLD3(0x04)
//
// [BATT]UPBI to XPBI
// Find:    55504249 00
// Replace: 58504249 00
//
// [BATT]UPBS to XPBS
// Find:    55504253 00
// Replace: 58504253 00
//
// [BATT]SMWR to XMWR
// Find:    534D5752 04
// Replace: 584D5752 04
//
// [BATT]SMRD to XMRD
// Find:    534D5244 04
// Replace: 584D5244 04
//
// [BATT]ACEL._STA to XSTA
// Find:    055F5354 4100A040
// Replace: 05585354 4100A040

DefinitionBlock ("", "SSDT", 2, "ERIC", "BATT", 0) {
    External (_SB.PCI0.LPCB.EC0, DeviceObj)
    External (_SB.GBFE, MethodObj)
    External (_SB.PBFE, MethodObj)
    External (_SB.BAT0, DeviceObj)
    External (_SB.BAT0.XPBI, MethodObj)
    External (_SB.BAT0.XPBS, MethodObj)
    External (_SB.PCI0.LPCB.EC0.XMWR, MethodObj)
    External (_SB.PCI0.LPCB.EC0.XMRD, MethodObj)
    External (_SB.PCI0.LPCB.EC0.MBNH, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.BVLB, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.BVHB, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.SW2S, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.BACR, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.MBST, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.ECOK, IntObj)
    External (_SB.PCI0.LPCB.EC0.MUT0, MutexObj)
    External (_SB.PCI0.LPCB.EC0.SMB0, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.SMW0, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.SMD0, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.SMST, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.SMCM, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.SMAD, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.SMPR, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.BCNT, FieldUnitObj)
    External (_SB.BAT0.PBIF, PkgObj)
    External (_SB.BAT0.FABL, IntObj)
    External (_SB.BAT0.PBST, PkgObj)
    External (_SB.BAT0.UPUM, MethodObj)
    External (_SB.BAT0._STA, MethodObj)
    External (_SB.PCI0.ACEL, DeviceObj)
    External (_SB.PCI0.ACEL.XSTA, MethodObj)

    
    Method (B1B2, 2, NotSerialized) 
    {
        // Bytes to Word
        // e.g. B1B2 (0x3A, 0x03) -> 0x033A
        return ((Arg0 | (Arg1 << 8)))
    }
    
    Method (W16B, 3, NotSerialized) 
    {
        // Word to Bytes
        // e.g. W16B (ARG0, ARG1, 0x033A) -> ARG0=0x3A, ARG1=0x03
        Arg0 = Arg2
        Arg1 = (Arg2 >> 8)
    }

    Method (WE1B, 2, NotSerialized) 
    {
        // Write 1 byte to EC
        // Arg0: Offset, Arg1: Byte to be written
        OperationRegion(ERM2, EmbeddedControl, Arg0, 1)    //OperationRegion (RegionName, RegionSpace, Offset, Length)
        Field (ERM2, ByteAcc, NoLock, Preserve) 
        {          
            // Field (RegionName, AccessType, LockRule, UpdateRule) {FieldUnitList}
            BYTE, 8
        }
        BYTE = Arg1    // Write
    }
    
    Method(WECB, 3, Serialized) 
    {
        // Write to EC field
        // Arg0: Offset, Arg1: Length, Arg2: Data to be written
        Arg1 = ((Arg1 + 7) >> 3)        // Arg1 = ceil(Arg1 / 8), this is loop counter
        Name (TEMP, Buffer (Arg1){})    // Initial buffer to be written
        TEMP = Arg2
        Arg1 += Arg0      // Shift write window to target area
        Local0 = 0        // Buffer index
        While ((Arg0 < Arg1)) {
            WE1B(Arg0, DerefOf(TEMP[Local0]))
            Arg0++        // Offset++
            Local0++      // Index++
        }
    }
    Method (RE1B, 1, NotSerialized)
    {
        OperationRegion (ERM2, EmbeddedControl, Arg0, One) 
        Field (ERM2, ByteAcc, NoLock, Preserve)
        {
            BYTE,   8 
        }

        Return (BYTE) 
    }

    Method (RECB, 2, Serialized)
    {
        // Read from EC field
        // Arg0: Offset, Arg1: Length
        Arg1 = ((Arg1 + 0x07) >> 0x03) 
        Name (TEMP, Buffer (Arg1){}) 
        Arg1 += Arg0 
        Local0 = Zero 
        While ((Arg0 < Arg1)) 
        {
            TEMP [Local0] = RE1B (Arg0) 
            Arg0++ 
            Local0++ 
        }

        Return (TEMP) 
    }

    
    Scope (\_SB.PCI0.LPCB.EC0) 
    {
        OperationRegion(ERM0, EmbeddedControl, 0, 0xFF)
        Field(ERM0, ByteAcc, Lock, Preserve) 
        {
            Offset(0x72),
            BFC0, 8,    // BFCC
            BFC1, 8,
            Offset(0x83),
            MCU0, 8,    // MCUR
            MCU1, 8,
            MBR0, 8,    // MBRM
            MBR1, 8,
            MBC0, 8,    // MBCV
            MBC1, 8
        }
        Field(ERM0, ByteAcc, NoLock, Preserve) 
        {
            Offset (0x04),
            MW00, 8,
            MW01, 8
        }
        Method (SMWR, 4, NotSerialized) 
        {
            If (_OSI("Darwin"))     // If OS match macOS
            {
                If (LNot (ECOK))
                {
                    Return (0xFF)
                }

                If (LNotEqual (Arg0, 0x06))
                {
                    If (LNotEqual (Arg0, 0x08))
                    {
                        If (LNotEqual (Arg0, 0x0A))
                        {
                            If (LNotEqual (Arg0, 0x46))
                            {
                                If (LNotEqual (Arg0, 0xC6))
                                {
                                    Return (0x19)
                                }
                            }
                        }
                    }
                }

                Acquire (MUT0, 0xFFFF)
                Store (0x04, Local0)
                While (LGreater (Local0, One))
                {
                    If (LEqual (Arg0, 0x06))
                    {
                        Store (Arg3, SMB0)
                    }

                    If (LEqual (Arg0, 0x46))
                    {
                        Store (Arg3, SMB0)
                    }

                    If (LEqual (Arg0, 0xC6))
                    {
                        Store (Arg3, SMB0)
                    }

                    If (LEqual (Arg0, 0x08))
                    {
                        //Store (Arg3, SMW0)
                        Local0 = 0
                        Local1 = 0
                        W16B(Local0, Local1, Arg3)
                        MW00 = Local0
                        MW01 = Local1
                    }

                    If (LEqual (Arg0, 0x0A))
                    {
                        //Store (Arg3, SMD0)
                        WECB (0x04, 0x100, Arg3)
                    }

                    And (SMST, 0x40, SMST)
                    Store (Arg2, SMCM)
                    Store (Arg1, SMAD)
                    Store (Arg0, SMPR)
                    Store (Zero, Local3)
                    While (LNot (And (SMST, 0xBF, Local1)))
                    {
                        Sleep (0x02)
                        Increment (Local3)
                        If (LEqual (Local3, 0x32))
                        {
                            And (SMST, 0x40, SMST)
                            Store (Arg2, SMCM)
                            Store (Arg1, SMAD)
                            Store (Arg0, SMPR)
                            Store (Zero, Local3)
                        }
                    }

                    If (LEqual (Local1, 0x80))
                    {
                        Store (Zero, Local0)
                    }
                    Else
                    {
                        Decrement (Local0)
                    }
                }

                If (Local0)
                {
                    Store (And (Local1, 0x1F), Local0)
                }

                Release (MUT0)
                Return (Local0)
            }
            Else 
            {    // Else call original method
                Return (\_SB.PCI0.LPCB.EC0.XMWR(Arg0, Arg1, Arg2, Arg3))
            }
        }
        Method (SMRD, 4, NotSerialized) 
        {
            If (_OSI("Darwin"))     // If OS match macOS
            {
                If (LNot (ECOK)) 
                {
                    Return (0xFF)
                }

                If (LNotEqual (Arg0, 0x07)) 
                {
                    If (LNotEqual (Arg0, 0x09)) 
                    {
                        If (LNotEqual (Arg0, 0x0B)) 
                        {
                            If (LNotEqual (Arg0, 0x47)) 
                            {
                                If (LNotEqual (Arg0, 0xC7)) 
                                {
                                    Return (0x19)
                                }
                            }
                        }
                    }
                }

                Acquire (MUT0, 0xFFFF)
                Store (0x04, Local0)
                While (LGreater (Local0, One))
                {
                    And (SMST, 0x40, SMST)
                    Store (Arg2, SMCM)
                    Store (Arg1, SMAD)
                    Store (Arg0, SMPR)
                    Store (Zero, Local3)
                    While (LNot (And (SMST, 0xBF, Local1)))
                    {
                        Sleep (0x02)
                        Increment (Local3)
                        If (LEqual (Local3, 0x32))
                        {
                            And (SMST, 0x40, SMST)
                            Store (Arg2, SMCM)
                            Store (Arg1, SMAD)
                            Store (Arg0, SMPR)
                            Store (Zero, Local3)
                        }
                    }

                    If (LEqual (Local1, 0x80))
                    {
                        Store (Zero, Local0)
                    }
                    Else
                    {
                        Decrement (Local0)
                    }
                }

                If (Local0)
                {
                    Store (And (Local1, 0x1F), Local0)
                }
                Else{
                    If (LEqual (Arg0, 0x07))
                    {
                        Store (SMB0, Arg3)
                    }

                    If (LEqual (Arg0, 0x47))
                    {
                        Store (SMB0, Arg3)
                    }

                    If (LEqual (Arg0, 0xC7))
                    {
                        Store (SMB0, Arg3)
                    }

                    If (LEqual (Arg0, 0x09))
                    {
                        //Store (SMW0, Arg3)
                        Arg3 = B1B2(MW00, MW01)
                    }

                    If (LEqual (Arg0, 0x0B))
                    {
                        Store (BCNT, Local3)
                        ShiftRight (0x0100, 0x03, Local2)
                        If (LGreater (Local3, Local2))
                        {
                            Store (Local2, Local3)
                        }

                        If (LLess (Local3, 0x09))
                        {
                            //Store (FLD0, Local2)
                            Local2 = RECB(0x04, 0x40)
                        }
                        ElseIf (LLess (Local3, 0x11))
                        {
                            //Store (FLD1, Local2)
                            Local2 = RECB(0x04, 0x80)
                        }
                        ElseIf (LLess (Local3, 0x19))
                        {
                            //Store (FLD2, Local2)
                            Local2 = RECB(0x04, 0xC0)
                        }
                        Else
                        {
                            //Store (FLD3, Local2)
                            Local2 = RECB(0x04, 0x100)
                        }

                        Increment (Local3)
                        Store (Buffer (Local3){}, Local4)
                        Decrement (Local3)
                        Store (Zero, Local5)
                        Name (OEMS, Buffer (0x46){})
                        ToBuffer (Local2, OEMS)
                        While (LGreater (Local3, Local5))
                        {
                            GBFE (OEMS, Local5, RefOf (Local6))
                            PBFE (Local4, Local5, Local6)
                            Increment (Local5)
                        }
                        PBFE (Local4, Local5, Zero)
                        Store (Local4, Arg3)
                    }
                }
                Release (MUT0)
                Return (Local0)
            }
            Else 
            {
                Return(\_SB.PCI0.LPCB.EC0.XMRD(Arg0, Arg1, Arg2, Arg3))
            }
        }
    }
    
    /*Scope(\_SB.PCI0.ACEL) {
        Method (_STA, 0, NotSerialized) {
            If (_OSI("Darwin")) {
                Return (0)
            }
            Else {
                Return(\_SB.PCI0.ACEL.XSTA())        // Cause Windows keyboard stop after sleep
            }
        }
    }*/
    
    
    Scope(\_SB.BAT0) 
    {    
        Method (UPBI, 0, NotSerialized) 
        {
            If (_OSI("Darwin")) 
            {
                Local5 = B1B2(^^PCI0.LPCB.EC0.BFC0, ^^PCI0.LPCB.EC0.BFC1)
                If (LAnd (Local5, LNot (And (Local5, 0x8000)))) 
                {
                    ShiftRight (Local5, 0x05, Local5)
                    ShiftLeft (Local5, 0x05, Local5)
                    Store (Local5, Index (PBIF, One))
                    Store (Local5, Index (PBIF, 0x02))
                    Divide (Local5, 0x64, , Local2)
                    Add (Local2, One, Local2)
                    Multiply (Local2, 0x0C, Local4)
                    Add (Local4, 0x02, Index (PBIF, 0x05))
                    Multiply (Local2, 0x07, Local4)
                    Add (Local4, 0x02, Index (PBIF, 0x06))
                    Multiply (Local2, 0x0A, Local4)
                    Add (Local4, 0x02, FABL)
                }

                If (^^PCI0.LPCB.EC0.MBNH) 
                {
                    Store (^^PCI0.LPCB.EC0.BVLB, Local0)
                    Store (^^PCI0.LPCB.EC0.BVHB, Local1)
                    ShiftLeft (Local1, 0x08, Local1)
                    Or (Local0, Local1, Local0)
                    Store (Local0, Index (PBIF, 0x04))
                    Store ("OANI$", Index (PBIF, 0x09))
                    Store ("NiMH", Index (PBIF, 0x0B))
                } 
                Else 
                {
                    Store (^^PCI0.LPCB.EC0.BVLB, Local0)
                    Store (^^PCI0.LPCB.EC0.BVHB, Local1)
                    ShiftLeft (Local1, 0x08, Local1)
                    Or (Local0, Local1, Local0)
                    Store (Local0, Index (PBIF, 0x04))
                    Sleep (0x32)
                    Store ("LION", Index (PBIF, 0x0B))
                }

                Store ("Primary", Index (PBIF, 0x09))
                UPUM ()
                Store (One, Index (PBIF, Zero))
            } 
            Else 
            {
                \_SB.BAT0.XPBI()
            }
        }
        Method (UPBS, 0, NotSerialized)
        {
            If (_OSI("Darwin")) 
            {
                Store (B1B2(^^PCI0.LPCB.EC0.MCU0, ^^PCI0.LPCB.EC0.MCU1), Local0)
                If (And (Local0, 0x8000))
                {
                    If (LEqual (Local0, 0xFFFF))
                    {
                        Store (0xFFFFFFFF, Index (PBST, One))
                    }
                    Else
                    {
                        Not (Local0, Local1)
                        Increment (Local1)
                        And (Local1, 0xFFFF, Local3)
                        Store (Local3, Index (PBST, One))
                    }
                }
                Else
                {
                    Store (Local0, Index (PBST, One))
                }

                Store (B1B2(^^PCI0.LPCB.EC0.MBR0, ^^PCI0.LPCB.EC0.MBR1), Local5)
                If (LNot (And (Local5, 0x8000)))
                {
                    ShiftRight (Local5, 0x05, Local5)
                    ShiftLeft (Local5, 0x05, Local5)
                    If (LNotEqual (Local5, DerefOf (Index (PBST, 0x02))))
                    {
                        Store (Local5, Index (PBST, 0x02))
                    }
                }

                If (LAnd (LNot (^^PCI0.LPCB.EC0.SW2S), LEqual (^^PCI0.LPCB.EC0.BACR, One)))
                {
                    Store (FABL, Index (PBST, 0x02))
                }

                Store (B1B2(^^PCI0.LPCB.EC0.MBC0, ^^PCI0.LPCB.EC0.MBC1), Index (PBST, 0x03))
                Store (^^PCI0.LPCB.EC0.MBST, Index (PBST, Zero))
            }
            Else 
            {
                \_SB.BAT0.XPBS()
            }
        }
		Method (CBIS, 0, Serialized)
        {
            Name (PKG1, Package (0x08)
            {
                // config, double check if you have valid AverageRate before
                // fliping that bit to 0x007F007F since it will disable quickPoll
                0x006F007F,
                // ManufactureDate (0x1), AppleSmartBattery format
                0xFFFFFFFF, 
                // PackLotCode (0x2)
                0xFFFFFFFF, 
                // PCBLotCode (0x3)
                0xFFFFFFFF, 
                // FirmwareVersion (0x4)
                0xFFFFFFFF, 
                // HardwareVersion (0x5)
                0xFFFFFFFF, 
                // BatteryVersion (0x6)
                0xFFFFFFFF, 
                0xFFFFFFFF, 
            })
            // Check your _BST method for similiar condition of EC accessibility
            If ((^^PCI0.LPCB.EC0.ECOK == 1))
            {
                PKG1 [One] = B1B2 (B1T1, B1T2)
                PKG1 [0x02] = B1B2 (FUSL, FUSH)
                PKG1 [0x03] = B1B2 (BMIL, BMIH)
                PKG1 [0x04] = B1B2 (FMVL, FMVH)
                PKG1 [0x05] = B1B2 (HIDL, HIDH)
                PKG1 [0x06] = B1B2 (DAVL, DAVH)
            }

            Return (PKG1)
        } // CBIS

        Method (CBSS, 0, Serialized)
        {
            Name (PKG1, Package (0x08)
            {
                // Temperature (0x10), AppleSmartBattery format
                0xFFFFFFFF, 
                // TimeToFull (0x11), minutes (0xFF)
                0xFFFFFFFF, 
                // TimeToEmpty (0x12), minutes (0)
                0xFFFFFFFF, 
                // ChargeLevel (0x13), percentage
                0xFFFFFFFF, 
                // AverageRate (0x14), mA (signed)
                0xFFFFFFFF, 
                // ChargingCurrent (0x15), mA
                0xFFFFFFFF, 
                // ChargingVoltage (0x16), mV
                0xFFFFFFFF, 
                0xFFFFFFFF
            })
            // Check your _BST method for similiar condition of EC accessibility
            If ((^^PCI0.LPCB.EC0.ECOK == 1))
            {
                PKG1 [Zero] = B1B2 (BTM1, BTM2)
                PKG1 [One] = B1B2 (BCL1, BCL2)
                PKG1 [0x02] = B1B2 (BCW1, BCW2)
                PKG1 [0x03] = B1B2 (BPR1, BPR2)
                PKG1 [0x04] = B1B2 (BAR1, BAR2)
                PKG1 [0x05] = B1B2 (BCC1, BCC2)
                PKG1 [0x06] = B1B2 (BCV1, BCV2)
            }

            Return (PKG1)
        } // CBSS
    }
}