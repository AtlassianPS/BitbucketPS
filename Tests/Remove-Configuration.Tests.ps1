Describe "Remove-Configuration" {

    Import-Module (Join-Path $PSScriptRoot "../BitbucketPS") -Prefix "Bitbucket" -Force -ErrorAction Stop

    InModuleScope BitbucketPS {

        . "$PSScriptRoot/shared.ps1"

        #region Mocking
        Mock Get-BitbucketConfiguration {
            ShowMockInfo 'Get-BitbucketConfiguration' 'ServerName', 'Uri'
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
            $script:Configuration.Server += [BitbucketPS.Server]@{
                Name          = "Pipe"
                Uri           = "http://google.com"
                IsCloudServer = $false
            }
        }
        #endregion Mocking

        Context "Sanity checking" {
            $command = Get-Command -Name Remove-BitbucketConfiguration

            defParam $command 'ServerName'
        }

        Context "Behavior checking" {

            #region Arrange
            BeforeEach {
                Set-BitbucketConfiguration -Uri "foo"
            }
            #endregion Arrange

            It "does not fail on invocation" {
                { Remove-BitbucketConfiguration -ServerName "foo" -ErrorAction SilentlyContinue } | Should Not Throw
                { Remove-BitbucketConfiguration -ServerName "foo" -ErrorAction Stop } | Should Throw
            }
            It "removes one entry of the servers" {
                (Get-BitbucketConfiguration).Count | Should Be 3
                Remove-BitbucketConfiguration -ServerName "Test2"
                (Get-BitbucketConfiguration).Count | Should Be 2
            }
            It "accepts an object over the pipeline" {
                (Get-BitbucketConfiguration).Count | Should Be 3
                (Get-BitbucketConfiguration).Name -contains "Pipe" | Should Be $true
                Get-BitbucketConfiguration -ServerName "Pipe" | Remove-BitbucketConfiguration
                (Get-BitbucketConfiguration).Count | Should Be 2
                (Get-BitbucketConfiguration).Name -contains "Pipe" | Should Be $false
            }
        }
    }
}
