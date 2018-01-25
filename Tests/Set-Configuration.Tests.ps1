Describe "Set-Configuration" {

    Import-Module (Join-Path $PSScriptRoot "../BitBucketPS") -Prefix "Bitbucket" -Force -ErrorAction Stop

    InModuleScope BitbucketPS {

        . "$PSScriptRoot/Shared.ps1"

        #region Mocking
        Mock Test-ServerType {
            ShowMockInfo 'Test-ServerType' 'Uri'
            if ($Uri -like "*fail*") {
                throw "Not Bitbucket Server"
            }
            elseif ($Uri -like "*cloud*") {
                $true
            }
            else {
                $false
            }
        }

        Mock Get-BitbucketConfiguration {
            ShowMockInfo 'Get-BitbucketConfiguration' 'Name','Uri'
            MockedDebug ($script:Configuration.Server | Out-String)
            $script:Configuration.Server | Where-Object { $_.Name -like "$ServerName*" }
        }

        function SetupConfiguration {
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

        #region Arrange
        SetupConfiguration
        #endregion Arrange

        Context "Sanity checking" {
            $command = Get-Command -Name Set-BitbucketConfiguration

            defParam $command 'ServerName'
            defParam $command 'Uri'
            defParam $command 'Session'
        }

        Context "Behavior checking" {
            It "does not fail on invocation" {
                { Set-BitbucketConfiguration -ServerName "foo" -Uri "https://google.com" -ErrorAction SilentlyContinue } | Should Not Throw
                { Set-BitbucketConfiguration -ServerName "foo" -Uri "https://google.com" -ErrorAction Stop } | Should Not Throw
                { Set-BitbucketConfiguration -Uri "https://google.com" } | Should Not Throw
                { Set-BitbucketConfiguration -Uri "https://google.com" -Session ([Microsoft.PowerShell.Commands.WebRequestSession]::new()) } | Should Not Throw
            }
            It "adds a new entry if it didn't exist before" {
                (Get-BitbucketConfiguration).Count | Should Be 4
                Set-BitbucketConfiguration -ServerName "bar" -Uri "https://google.com"
                (Get-BitbucketConfiguration).Count | Should Be 5
                ((Get-BitbucketConfiguration).Name -contains "bar") | Should Be $true
            }
            It "overwrite an entry in case in existed before" {
                (Get-BitbucketConfiguration).Count | Should Be 5
                Set-BitbucketConfiguration -ServerName "Test1" -Uri "https://google.com"
                (Get-BitbucketConfiguration).Count | Should Be 5
            }
            It "tries to figure out if the server is a bitbucket cloud server or on premise" {
                Set-BitbucketConfiguration -ServerName "cloudYes" -Uri "https://google.com/cloud"
                Set-BitbucketConfiguration -ServerName "cloudNo" -Uri "https://google.com/"
                (Get-BitbucketConfiguration)[-2].IsCloudServer | Should Be $true
                (Get-BitbucketConfiguration)[-1].IsCloudServer | Should Be $false
            }
            It "fails if the server is not a bitbucket server" {
                (Get-BitbucketConfiguration).Count | Should Be 7
                { Set-BitbucketConfiguration -ServerName "noBitbucket" -Uri "https://google.com/fail" } | Should Throw
                (Get-BitbucketConfiguration).Count | Should Be 7
            }
            It "uses the server Authority if no name was provided" {
                (Get-BitbucketConfiguration).Count | Should Be 7
                Set-BitbucketConfiguration -Uri "https://www.google.com/"
                (Get-BitbucketConfiguration).Count | Should Be 8
                (Get-BitbucketConfiguration)[-1].Name | Should Be "www.google.com"
            }
            It "changes an entry over pipeline" {
                (Get-BitbucketConfiguration).Count | Should Be 8
                Get-BitbucketConfiguration -ServerName "Test1" | Set-BitbucketConfiguration -Uri "http://new.com/"
                (Get-BitbucketConfiguration).Count | Should Be 8
                (Get-BitbucketConfiguration)[-1].Name | Should Be "Test1"
                (Get-BitbucketConfiguration)[-1].Uri | Should Be "http://new.com/"
            }
            It "adds a new entry over pipeline with new Name" {
                (Get-BitbucketConfiguration).Count | Should Be 8
                $serverEntry = Get-BitbucketConfiguration -ServerName "Test2"
                $serverEntry | Set-BitbucketConfiguration -ServerName "NewValue"
                (Get-BitbucketConfiguration).Count | Should Be 9
                (Get-BitbucketConfiguration)[-1].Name | Should Be "NewValue"
                (Get-BitbucketConfiguration)[-1].Uri | Should Be $serverEntry.Uri
            }
        }
    }
}
