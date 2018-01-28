Describe "Get-Configuration" {

    Import-Module (Join-Path $PSScriptRoot "../BitbucketPS") -Prefix "Bitbucket" -Force -ErrorAction Stop

    InModuleScope BitbucketPS {

        . "$PSScriptRoot/shared.ps1"

        #region Mocking
        Mock Set-BitbucketConfiguration {
            $script:Configuration.Server = @()
            $script:Configuration.Server += [BitbucketPS.Server]@{
                Name = "Test1"
                Uri  = "https://google.com"
            }
            $script:Configuration.Server += [BitbucketPS.Server]@{
                Name = "Test2"
                Uri  = "http://google.com"
            }
        }
        #endregion Mocking

        Context "Sanity checking" {
            $command = Get-Command -Name Get-BitbucketConfiguration

            defParam $command 'ServerName'
            defParam $command 'Uri'
        }

        Context "Behavior checking" {

            #region Arrange
            BeforeEach {
                Set-BitbucketConfiguration -Uri "foo"
            }
            #endregion Arrange

            It "does not fail on invocation" {
                # As this uses values that are not stored, we do not need separate
                # tests for when no value is found.
                { Get-BitbucketConfiguration } | Should Not Throw
                { Get-BitbucketConfiguration -ErrorAction Stop } | Should Not Throw
                { Get-BitbucketConfiguration -ServerName "foo" } | Should Not Throw
                { Get-BitbucketConfiguration -Uri "bar" } | Should Not Throw
            }
            It "retrieves all server in memory" {
                $servers = Get-BitbucketConfiguration
                $servers.Count | Should Be 2
            }
            It "finds a server by it's name" {
                $server = Get-BitbucketConfiguration -ServerName "Test1"
                $server | Should Not BeNullOrEmpty
                $server.Count | Should Be 1
                checkType $server 'BitbucketPS.Server'
                $server.Name | Should Be "Test1"
                $server.Uri | Should Be "https://google.com/"
                $server.Uri.AbsoluteUri | Should Be "https://google.com/"
            }
            It "finds a server by it's uri" {
                $server = Get-BitbucketConfiguration -Uri "http://google.com"
                $server | Should Not BeNullOrEmpty
                $server.Count | Should Be 1
                checkType $server 'BitbucketPS.Server'
                $server.Name | Should Be "Test2"
                $server.Uri | Should Be "http://google.com/"
                $server.Uri.AbsoluteUri | Should Be "http://google.com/"
            }
        }
    }
}
