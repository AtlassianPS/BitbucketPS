$ModuleInformation = @{
    Path            = "C:\Dropbox\athenaGIT\BitbucketPS"
    TargetPath      = "C:\Dropbox\athenaGIT\BitbucketPS"
    ModuleName      = "BitbucketPS"
    ReleaseNotes    = (git log -1 --pretty=%s) | Out-String
    Author          = "Joe Beaudry"
    Company         = "Atlassian"
    Description     = "PowerShell module to interact with Atlassian Bitbucket "
    ProjectURI      = "https://github.com/AtlassianPS/BitbucketPS"
    LicenseURI      = "https://github.com/AtlassianPS/BitbucketPS/blob/master/LICENSE"
    PassThru        = $true
}

Invoke-PSModuleBuild @ModuleInformation