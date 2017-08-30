$here = Split-Path -Parent $MyInvocation.MyCommand.Path

#Get information from the module manifest
$manifestPath = "$here\..\..\PSMitrend\PSMitrend.psd1"
$manifest = Test-ModuleManifest -Path $manifestPath

#Test if a PSMitrend module is already loaded
$Module = Get-Module -Name 'PSMitrend' -ErrorAction SilentlyContinue

#Load the module if needed (not already loaded or not the good version)
If ($Module) {
    If ($Module.Version -ne $manifest.version) {
        Remove-Module $Module
        $Module = Import-Module "$here\..\..\PSMitrend" -Version $manifest.version -force
    }
} else {
    $Module = Import-Module "$here\..\..\PSMitrend" -Version $manifest.version -force
}

#Import data
. $here\Unit.Data.ps1

Describe -Name "Unit test for Request-Parameters" {

    Mock -ModuleName PSMitrend -ParameterFilter {$uri -eq 'https://app.mitrend.com/api/assessments'} Invoke-RestMethod {
        return $Global:RequestResponse
    }

    Mock -ModuleName PSMitrend -ParameterFilter {$uri -like 'https://app.mitrend.com/api/*/files'} Invoke-RestMethod {
        return $Global:FileResponse
    }

    Mock -ModuleName PSMitrend -ParameterFilter {$uri -like 'https://app.mitrend.com/api/*/submit'} Invoke-RestMethod {
        return $Global:FileResponse
    }

    Context -Name 'Attaching files' {

        It -Name 'Should not throw when attaching 1 valid file to the assessment' {
            $File = "$here\Files\MyFile01.zip"
            {Request-Assessment -Credentials $MockCredentials -AssessmentName $MockAssessmentName -Company $MockCompany -File $File -deviceType $MockdeviceType} | Should Not Throw
        }
        It -Name 'Should throw when attaching 1 unexistent file to the assessment' {
            $File = "$here\Files\WrongFile.zip"
            {Request-Assessment -Credentials $MockCredentials -AssessmentName $MockAssessmentName -Company $MockCompany -File $File -deviceType $MockdeviceType} | Should Throw
        }
        It -Name 'Should call Invoke-RestMethod 3 times when attaching 1 file' {
            $File = "$here\Files\MyFile01.zip"
            Request-Assessment -Credentials $MockCredentials -AssessmentName $MockAssessmentName -Company $MockCompany -File $File -deviceType $MockdeviceType
            Assert-MockCalled -ModuleName PSMitrend -CommandName 'Invoke-RestMethod' -Exactly 3 -Scope It
        }
        It -Name 'Should not throw when attaching 2 valid files to the assessment' {
            $File = @("$here\Files\MyFile01.zip","$here\Files\MyFile02.zip")
            {Request-Assessment -Credentials $MockCredentials -AssessmentName $MockAssessmentName -Company $MockCompany -File $File -deviceType $MockdeviceType} | Should Not Throw
        }
        It -Name 'Should throw when attaching 2 unexistent files to the assessment' {
            $File = @("$here\Files\WrongFile01.zip","$here\Files\WrongFile02.zip")
            {Request-Assessment -Credentials $MockCredentials -AssessmentName $MockAssessmentName -Company $MockCompany -File $File -deviceType $MockdeviceType} | Should Throw
        }
        It -Name 'Should call Invoke-RestMethod 4 times when attaching 1 file' {
            $File = @("$here\Files\MyFile01.zip","$here\Files\MyFile02.zip")
            Request-Assessment -Credentials $MockCredentials -AssessmentName $MockAssessmentName -Company $MockCompany -File $File -deviceType $MockdeviceType
            Assert-MockCalled -ModuleName PSMitrend -CommandName 'Invoke-RestMethod' -Exactly 4 -Scope It
        }
    }
}
