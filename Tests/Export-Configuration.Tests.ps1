Import-Module (Join-Path $PSScriptRoot "../BitBucketPS") -ErrorAction Stop

InModuleScope BitbucketPS {

    . $PSScriptRoot\Shared.ps1

    Describe "Export-Configuration" {

        #region Mocking
        Mock Export-Configuration -ModuleName "Configuration" {
            $InputObject
        }
        #endregion Mocking

        #region Arrange
        $script:Configuration.Server = @()
        $script:Configuration.Server += [BitbucketPS.Server]@{
            Name = "Test1"
            Uri  = "https://google.com"
            Session = ([Microsoft.PowerShell.Commands.WebRequestSession]::new())
            IsCloudServer = $true
        }
        $script:Configuration.Server += [BitbucketPS.Server]@{
            Name = "Test2"
            Uri  = "http://google.com"
            IsCloudServer = $false
        }
        #endregion Arrange

        Context "Sanity checking" { }

        Context "Behavior checking" {
            It "does not fail on invocation" {
                {Export-BitbucketConfiguration} | Should Not Throw
            }
            It "uses the Configuration module to export the data" {
                # Export-BitbucketConfiguration
                # Assert-MockCalled -CommandName "Export-Configuration" -ModuleName "Configuration" -Exactly -Times 1 -Scope It
            }
            It "does not allow sessions to be exported" {
                $before = $script:Configuration.Server
                $after = Export-BitbucketConfiguration
                $before.Session.UserAgent | Should Be $true
                $after.Session.UserAgent | Should BeNullOrEmpty
            }
        }
    }
}
