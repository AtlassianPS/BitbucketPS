Function Get-ProjectKey {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$Repo
    )

    Validate-Session

    Write-Verbose "Getting Project Key of:"
    Write-Verbose "   RepoName: $Repo"
    Write-Verbose "     Server: $($Global:BBSession.Server)"

    Get-Repository | Where-Object slug -match $Repo | Select -ExpandProperty Project
}
