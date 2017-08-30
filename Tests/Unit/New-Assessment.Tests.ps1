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

Describe -Name "Unit tests for New-Assessment" {

    Context -Name 'Testing with valid parameters' {

        Mock -ModuleName PSMitrend Invoke-RestMethod {$Global:RequestResponse} -ParameterFilter {$uri -eq 'https://app.mitrend.com/api/assessments'}

        It -Name 'Should Not Throw' {
            {New-Assessment -Credentials $MockCredentials -AssessmentName $MockAssessmentName -Company $MockCompany} | Should Not Throw
        }

        It -Name "Assessment ID should be $MockAssessmentID" {
            $Assessment = New-Assessment -Credentials $MockCredentials -AssessmentName $MockAssessmentName -Company $MockCompany
            $Assessment.id | Should Be $MockAssessmentID
        }
    }

    Context -Name 'Testing Invoke-RestMethod calls' {
        Mock -ModuleName PSMitrend Invoke-RestMethod {$Global:RequestResponse} -ParameterFilter {$uri -eq 'https://app.mitrend.com/api/assessments'}

        It -Name 'Calls Invoke-RestMethod exactly 1 time' {
            $Assessment = New-Assessment -Credentials $MockCredentials -AssessmentName $MockAssessmentName -Company $MockCompany
            Assert-MockCalled -ModuleName PSMitrend -CommandName 'Invoke-RestMethod' -Exactly 1 -Scope It
        }

        Mock -ModuleName PSMitrend Invoke-RestMethod {Throw [System.Net.WebException] "API Error"} -ParameterFilter {$uri -eq 'https://app.mitrend.com/api/assessments'}

        It "Should Throw if Invoke-RestMethod return an error" {
            {New-Assessment -Credentials $MockCredentials -AssessmentName $MockAssessmentName -Company $MockCompany} | Should Throw
        }
    }
}
