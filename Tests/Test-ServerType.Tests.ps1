Describe "Test-ServerType" {

    Import-Module (Join-Path $PSScriptRoot "../BitbucketPS") -Prefix "Bitbucket" -Force -ErrorAction Stop

    InModuleScope BitbucketPS {

        . "$PSScriptRoot/Shared.ps1"

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
