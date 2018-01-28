[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
param()

Describe "New-Session" {

    Import-Module (Join-Path $PSScriptRoot "../BitbucketPS") -Prefix "Bitbucket" -Force -ErrorAction Stop

    InModuleScope BitbucketPS {

        . "$PSScriptRoot/shared.ps1"

        #region Mocking
        Mock Invoke-Method { $true }
        Mock Get-Configuration -ModuleName BitbucketPS {
            [BitbucketPS.Server]@{
                Name = "myServer"
                Uri  = "https://google.com"
            }
        }
        Mock Set-Configuration { }
        #endregion Mocking

        #region Arrange
        $testPassword = ConvertTo-SecureString -String 'test123' -AsPlainText -Force
        $credentials = New-Object -TypeName PSCredential -ArgumentList "user", $testPassword

        #endregion Arrange

        Context "Sanity checking" {
            $command = Get-Command -Name New-Session

            defParam $command 'ServerName'
            defParam $command 'Credential'
            defParam $command 'Headers'
        }

        Context "Behavior checking" {
            It "does not fail on invocation" {
                { New-BitbucketSession -Name "myServer" -Credential $credentials } | Should Not Throw
            }
            It "uses Invoke-Method to authenticate" {
                New-BitbucketSession -Name "myServer" -Credential $credentials
                Assert-MockCalled -CommandName Invoke-Method -Exactly -Times 1 -Scope It -ParameterFilter {$Method -eq "Get"}
            }
            It "adds the session to an existing server" {
                New-BitbucketSession -Name "myServer" -Credential $credentials
                Assert-MockCalled -CommandName Get-Configuration -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Set-Configuration -Exactly -Times 1 -Scope It
            }
        }
    }
}
