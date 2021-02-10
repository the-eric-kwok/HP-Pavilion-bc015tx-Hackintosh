DefinitionBlock ("", "SSDT", 2, "ERIC", "KeyBd", 0)
{
    External(_SB.PCI0.LPCB.PS2K, DeviceObj)
    Scope (_SB.PCI0.LPCB.PS2K)
    {
        Name (RMCF,Package() 
        {
            "Keyboard", Package()
            {
                "Custom ADB Map", Package()
                {
                    Package(){},
                    "e05b=3a",    // Left Windows to Command
                    "38=37",      // Left alt to Option
                    "e038=3a"     // Right alt to Command
                },
				
				// Comment below 2 lines to map prtsc as F13 
				// (So that you can set them as a hotkey of screen shot)
				"RemapPrntScr", 
                ">y"
            },
        })
    }
}