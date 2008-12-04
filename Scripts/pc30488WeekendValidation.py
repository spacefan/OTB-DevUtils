import sys
import os
import platform
import socket

if __name__ == "__main__":
        sys.path.append(os.getcwd()+"/OTB-DevUtils/Scripts")
        try:
                import Validation
        except:
                print 'Impossible to find Validation module (import Validation abort!!)'
                exit(1)

        x=Validation.TestProcessing()
        x.SetRunDir("G:\\")
        x.SetOutilsDir("G:\\")
        x.SetOtbDataLargeInputDir("G:\\OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()
        x.SetSourcesDir("Z:\\")
        x.DisableUpdateSources()

        x.DisableTestOTBApplicationsWithInstallOTB()
        x.DisableUseVtk()
        x.DisableGlUseAccel()
        x.DisableBuildExamples()

        x.EnableGenerateMakefiles()
        
#        x.DisableCTest()

        # List of platform must been tested
        x.Run("visual7-static-debug-itk-internal-fltk-internal")
        x.Run("visual7-static-release-itk-internal-fltk-internal")
        x.Run("visual7-static-debug-itk-external-fltk-external")
        x.Run("visual7-static-release-itk-external-fltk-external")

