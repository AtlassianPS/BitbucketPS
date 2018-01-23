Describe "Import-MqcnAlias" {

    Import-Module (Join-Path $PSScriptRoot "../BitBucketPS") -Prefix "Bitbucket" -Force -ErrorAction Stop

    InModuleScope BitbucketPS {

        . "$PSScriptRoot/shared.ps1"

        #region Mocking
        #endregion Mocking

        #region Arrange
        #endregion Arrange

        Context "Sanity checking" {
            $command = Get-Command -Name Import-MqcnAlias

            defParam $command 'Alias'
            defParam $command 'Command'
        }

        Context "Behavior checking" {
            It "creates an alias in the module's scope" {
                Import-MqcnAlias -Alias "aa" -Command "Microsoft.PowerShell.Management\Get-Item"
                Get-Alias -Name "aa" -Scope "Local" -ErrorAction Ignore | Should Be $true
            }
            It "does not make the alias available outside of the module" {
                Import-MqcnAlias -Alias "ab" -Command "Microsoft.PowerShell.Management\Get-Item"
                Get-Alias -Name "ab" -Scope "Global" -ErrorAction Ignore | Should BeNullOrEmpty
                Get-Alias -Name "ab" -Scope "Script" -ErrorAction Ignore | Should BeNullOrEmpty
            }
        }
    }
}
