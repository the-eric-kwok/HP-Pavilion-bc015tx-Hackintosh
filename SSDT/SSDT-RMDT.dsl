// for use with ACPIDebug
// This file was created by applying "Add DSDT Debug Methods" to an empty SSDT
//
// Use "Add SSDT Debug Extern Declarations" to access these methods from other
// hotpatch SSDTs or even patched OEM ACPI files.
//
DefinitionBlock("", "SSDT", 2, "OCLT", "RMDT", 0)
{
    If (_OSI ("Darwin"))
    {
        Device (RMDT)
        {
            Name (_HID, "RMD0000")  // _HID: Hardware ID
            Name (RING, Package (0x0100){})
            Mutex (RTMX, 0x00)
            Name (HEAD, Zero)
            Name (TAIL, Zero)
            
            // PUSH: Use to push a trace item into RING for ACPIDebug.kext
            Method (PUSH, 1, NotSerialized)
            {
                Acquire (RTMX, 0xFFFF)
                // push new item at HEAD
                Local0 = (HEAD + One)
                If ((Local0 >= SizeOf (RING)))
                {
                    Local0 = Zero
                }

                If ((Local0 != TAIL))
                {
                    RING [HEAD] = Arg0
                    HEAD = Local0
                }

                Release (RTMX)
                Notify (RMDT, 0x80) // Status Change
            }

            // FTCH: Used by ACPIDebug.kext to fetch an item from RING
            Method (FTCH, 0, NotSerialized)
            {
                Acquire (RTMX, 0xFFFF)
                // pull item from TAIL and return it
                Local0 = Zero
                If ((HEAD != TAIL))
                {
                    Local0 = DerefOf (RING [TAIL])
                    TAIL++
                    If ((TAIL >= SizeOf (RING)))
                    {
                        TAIL = Zero
                    }
                }

                Release (RTMX)
                Return (Local0)
            }
            
            // COUN: Used by ACPIDebug.kext to determine number of items in RING
            Method (COUN, 0, NotSerialized)
            {
                Acquire (RTMX, 0xFFFF)
                // return count of items in RING
                Local0 = (HEAD - TAIL) /* \RMDT.TAIL */
                If ((Local0 < Zero))
                {
                    Local0 += SizeOf (RING)
                }

                Release (RTMX)
                Return (Local0)
            }
            
            // Helper functions for multiple params at one time
            Method (P1, 1, NotSerialized)
            {
                PUSH (Arg0)
            }

            Method (P2, 2, NotSerialized)
            {
                Local0 = Package (0x02){}
                Local0 [Zero] = Arg0
                Local0 [One] = Arg1
                PUSH (Local0)
            }

            Method (P3, 3, NotSerialized)
            {
                Local0 = Package (0x03){}
                Local0 [Zero] = Arg0
                Local0 [One] = Arg1
                Local0 [0x02] = Arg2
                PUSH (Local0)
            }

            Method (P4, 4, NotSerialized)
            {
                Local0 = Package (0x04){}
                Local0 [Zero] = Arg0
                Local0 [One] = Arg1
                Local0 [0x02] = Arg2
                Local0 [0x03] = Arg3
                PUSH (Local0)
            }

            Method (P5, 5, NotSerialized)
            {
                Local0 = Package (0x05){}
                Local0 [Zero] = Arg0
                Local0 [One] = Arg1
                Local0 [0x02] = Arg2
                Local0 [0x03] = Arg3
                Local0 [0x04] = Arg4
                PUSH (Local0)
            }

            Method (P6, 6, NotSerialized)
            {
                Local0 = Package (0x06){}
                Local0 [Zero] = Arg0
                Local0 [One] = Arg1
                Local0 [0x02] = Arg2
                Local0 [0x03] = Arg3
                Local0 [0x04] = Arg4
                Local0 [0x05] = Arg5
                PUSH (Local0)
            }

            Method (P7, 7, NotSerialized)
            {
                Local0 = Package (0x07){}
                Local0 [Zero] = Arg0
                Local0 [One] = Arg1
                Local0 [0x02] = Arg2
                Local0 [0x03] = Arg3
                Local0 [0x04] = Arg4
                Local0 [0x05] = Arg5
                Local0 [0x06] = Arg6
                PUSH (Local0)
            }
        }
    }
}
//EOF