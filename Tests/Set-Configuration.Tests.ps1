Import-Module (Join-Path $PSScriptRoot "../BitBucketPS") -Force -ErrorAction Stop

InModuleScope BitbucketPS {

    . $PSScriptRoot\Shared.ps1

    Describe "Set-Configuration" {

        #region Mocking
        $PSDefaultParameterValues["Mock:ModuleName"] = "BitbucketPS"

        Mock Test-ServerType {
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
            [BitbucketPS.Server]@{
                Name = "Pipe"
                Uri  = "http://google.com"
                IsCloudServer = $false
            }
        }
        #endregion Mocking

        #region Arrange
        $script:Configuration.Server = @()
        $script:Configuration.Server += [BitbucketPS.Server]@{
            Name = "Test1"
            Uri  = "https://google.com"
        }
        $script:Configuration.Server += [BitbucketPS.Server]@{
            Name = "Test2"
            Uri  = "http://google.com"
        }
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
                $script:Configuration.Server.Count | Should Be 4
                Set-BitbucketConfiguration -ServerName "bar" -Uri "https://google.com"
                $script:Configuration.Server.Count | Should Be 5
                ($script:Configuration.Server.Name -contains "bar") | Should Be $true
            }
            It "overwrite an entry in case in existed before" {
                $script:Configuration.Server.Count | Should Be 5
                Set-BitbucketConfiguration -ServerName "Test1" -Uri "https://google.com"
                $script:Configuration.Server.Count | Should Be 5
            }
            It "tries to figure out if the server is a bitbucket cloud server or on premise" {
                Set-BitbucketConfiguration -ServerName "cloudYes" -Uri "https://google.com/cloud"
                Set-BitbucketConfiguration -ServerName "cloudNo" -Uri "https://google.com/"
                $script:Configuration.Server[-2].IsCloudServer | Should Be $true
                $script:Configuration.Server[-1].IsCloudServer | Should Be $false
            }
            It "fails if the server is not a bitbucket server" {
                $script:Configuration.Server.Count | Should Be 7
                { Set-BitbucketConfiguration -ServerName "noBitbucket" -Uri "https://google.com/fail" } | Should Throw
                $script:Configuration.Server.Count | Should Be 7
            }
            It "uses the server Authority if no name was provided" {
                $script:Configuration.Server.Count | Should Be 7
                Set-BitbucketConfiguration -Uri "https://www.google.com/"
                $script:Configuration.Server.Count | Should Be 8
                $script:Configuration.Server[-1].Name | Should Be "www.google.com"
            }
            It "accepts an object over the pipeline" {
                $script:Configuration.Server.Count | Should Be 8
                Get-BitbucketConfiguration -ServerName "dummy" | Set-BitbucketConfiguration
                $script:Configuration.Server.Count | Should Be 9
                $script:Configuration.Server[-1].Name | Should Be "Pipe"
            }
        }
    }
}
