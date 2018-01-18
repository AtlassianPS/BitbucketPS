Import-Module (Join-Path $PSScriptRoot "../BitBucketPS") -Force -ErrorAction Stop

InModuleScope BitbucketPS {

    . $PSScriptRoot\Shared.ps1

    Describe "Remove-Configuration" {

        #region Mocking
        $PSDefaultParameterValues["Mock:ModuleName"] = "BitbucketPS"

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
        $script:Configuration.Server += [BitbucketPS.Server]@{
            Name = "Pipe"
            Uri  = "http://google.com"
            IsCloudServer = $false
        }
        #endregion Arrange

        Context "Sanity checking" {
            $command = Get-Command -Name Get-BitbucketConfiguration

            defParam $command 'ServerName'
        }

        Context "Behavior checking" {
            It "does not fail on invocation" {
                { Remove-BitbucketConfiguration -ServerName "foo" -ErrorAction SilentlyContinue } | Should Not Throw
                { Remove-BitbucketConfiguration -ServerName "foo" -ErrorAction Stop } | Should Throw
            }
            It "removes one entry of the servers" {
                $script:Configuration.Server.Count | Should Be 3
                Remove-BitbucketConfiguration -ServerName "Test2"
                $script:Configuration.Server.Count | Should Be 2
            }
            It "accepts an object over the pipeline" {
                $script:Configuration.Server.Count | Should Be 2
                $script:Configuration.Server.Name -contains "Pipe" | Should Be $true
                Get-BitbucketConfiguration -ServerName "dummy" | Remove-BitbucketConfiguration
                $script:Configuration.Server.Count | Should Be 1
                $script:Configuration.Server.Name -contains "Pipe" | Should Be $false
            }
        }
    }
}
