Describe "Export-Configuration" {

    Import-Module (Join-Path $PSScriptRoot "../BitbucketPS") -Prefix "Bitbucket" -Force -ErrorAction Stop

    InModuleScope BitbucketPS {

        . "$PSScriptRoot/shared.ps1"

        #region Mocking
        Mock Import-MqcnAlias {}

        function ExportConfiguration {}
        Mock ExportConfiguration {
            ShowMockInfo 'ExportConfiguration' 'InputObject'
            $InputObject
        }

        Mock Get-BitbucketConfiguration {
            ShowMockInfo 'Get-BitbucketConfiguration' 'Name', 'Uri'
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

        Context "Sanity checking" { }

        Context "Behavior checking" {

            #region Arrange
            BeforeEach {
                Set-BitbucketConfiguration -Uri "foo"
            }
            #endregion Arrange

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
                $before.Session.UserAgent | Should Not BeNullOrEmpty
                $after.Session.UserAgent | Should BeNullOrEmpty
            }
        }
    }
}
