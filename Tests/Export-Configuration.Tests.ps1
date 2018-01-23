Describe "Export-Configuration" {

    Import-Module (Join-Path $PSScriptRoot "../BitBucketPS") -Prefix "Bitbucket" -Force -ErrorAction Stop

    InModuleScope BitbucketPS {

        . $PSScriptRoot\Shared.ps1

        #region Mocking
        Mock Import-MqcnAlias {}

        function ExportConfiguration {}
        Mock ExportConfiguration {
            $InputObject
        }

        Mock Get-BitbucketConfiguration {
            MockedDebug ($script:Configuration.Server | Out-String)
            $script:Configuration.Server | Where-Object { $_.Name -like "$ServerName*" }
        }

        Mock Set-BitbucketConfiguration {
            $script:Configuration.Server = @()
            $script:Configuration.Server += [BitbucketPS.Server]@{
                Name          = "Test1"
                Uri           = "https://google.com"
                Session       = ([Microsoft.PowerShell.Commands.WebRequestSession]::new())
                IsCloudServer = $true
            }
            $script:Configuration.Server += [BitbucketPS.Server]@{
                Name          = "Test2"
                Uri           = "http://google.com"
                IsCloudServer = $false
            }
        }
        #endregion Mocking

        #region Arrange
        Set-BitbucketConfiguration -Uri "foo"
        #endregion Arrange

        Context "Sanity checking" { }

        Context "Behavior checking" {
            It "does not fail on invocation" {
                { Export-BitbucketConfiguration } | Should Not Throw
            }
            It "uses the Configuration module to export the data" {
                Export-BitbucketConfiguration
                Assert-MockCalled -CommandName "ExportConfiguration" -ModuleName "BitbucketPS" -Exactly -Times 1 -Scope It
            }
            It "does not allow sessions to be exported" {
                $before = Get-BitbucketConfiguration
                $after = Export-BitbucketConfiguration
                $before.Session.UserAgent | Should Be $true
                $after.Session.UserAgent | Should BeNullOrEmpty
            }
        }
    }
}
