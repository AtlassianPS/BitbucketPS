Import-Module (Join-Path $PSScriptRoot "../BitBucketPS") -Force -ErrorAction Stop

Describe "Test-ServerType" {

    . $PSScriptRoot\Shared.ps1

    InModuleScope BitbucketPS {

        #region Mocking
        #endregion Mocking

        #region Arrange
        #endregion Arrange

        Context "Sanity checking" {
            $command = Get-Command -Name Test-ServerType

            defParam $command 'Uri'
            defParam $command 'Headers'
        }

        Context "Behavior checking" {
            It "checks the headers of the HTTP response for bitbucket specifics" {}
        }
    }
}
