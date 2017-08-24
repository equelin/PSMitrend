$here = Split-Path -Parent $MyInvocation.MyCommand.Path

#Get information from the module manifest
$manifestPath = "$here\..\..\PSMitrend\PSMitrend.psd1"
$manifest = Test-ModuleManifest -Path $manifestPath

#Test if a PSMitrend module is already loaded
$Module = Get-Module -Name 'PSMitrend' -ErrorAction SilentlyContinue

#Load the module if needed
If ($module) {
    If ($Module.Version -ne $manifest.version) {
        Remove-Module $Module
        Import-Module "$here\..\..\PSMitrend" -Version $manifest.version -force
    }
} else {
    Import-Module "$here\..\..\PSMitrend" -Version $manifest.version -force
}

Describe -Tags 'VersionChecks' "PSMitrend manifest" {
    $script:manifest = $null
    It "has a valid manifest" {
        {
            $script:manifest = Test-ModuleManifest -Path $manifestPath -ErrorAction Stop -WarningAction SilentlyContinue
        } | Should Not Throw
    }

    It "has a valid name in the manifest" {
        $script:manifest.Name | Should Be 'PSMitrend'
    }

    It "has a valid guid in the manifest" {
        $script:manifest.Guid | Should Be '446d99b9-c546-4d2a-adc9-8ed0a9414f4c'
    }

    It "has a valid version in the manifest" {
        $script:manifest.Version -as [Version] | Should Not BeNullOrEmpty
    }
}
