Function Get-BBProjectKey {    
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$Repo
    )

    ValidateBBSession

    Write-Verbose "Getting Project Key of:"
    Write-Verbose "   RepoName: $Repo"
    Write-Verbose "     Server: $($Global:BBSession.Server)"

    Get-BBRepositories | Where-Object slug -match $Repo | Select -ExpandProperty Project
}