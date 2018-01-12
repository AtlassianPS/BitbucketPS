Function Get-BBRepositories {    
    [CmdletBinding()]
    Param (
        [string]$Repo
    )

    ValidateBBSession
   
    Write-Verbose "Getting Repos:"
    Write-Verbose "   RepoName: $Repo"
    Write-Verbose "     Server: $($Global:BBSession.Server)"

    $Uri = "$($Global:BBSession.Server)/rest/api/1.0/repos"

    Invoke-BBMethod -Uri $Uri -Credential $Global:BBSession.Credential -Method GET | Where name -match $Repo
}
