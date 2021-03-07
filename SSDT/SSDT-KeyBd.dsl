DefinitionBlock ("", "SSDT", 2, "ERIC", "KeyBd", 0)
{
    External(_SB.PCI0.LPCB.PS2K, DeviceObj)
    Scope (_SB.PCI0.LPCB.PS2K)
    {
        Name (RMCF,Package() 
        {
            "Keyboard", Package()
            {
				// Comment below 8 lines to unmap right alt to command
                "Custom ADB Map", 
                Package (0x04)
                {
                    Package (0x00){}, 
                    "e05b=37", 
                    "38=3a", 
                    "e038=37"
                }, 
				
				// Comment below 2 lines to map prtsc as F13 
				// (So that you can set them as a hotkey of screen shot)
				"RemapPrntScr", 
                ">y"
            },
        })
    }
}