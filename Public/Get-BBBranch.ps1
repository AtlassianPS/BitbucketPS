Function Get-BBBranch {    
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$Branch,

        [Parameter(Mandatory)]
        [string]$Repo
    )

    ValidateBBSession

    Write-Verbose "Getting Branch:"
    Write-Verbose "     Repo: $Repo"
    Write-Verbose "   Branch: $Branch"
    Write-Verbose "   Server: $($Global:BBSession.Server)"

    Get-BBBranchList -Repo $Repo | Where-Object displayId -match $Branch
}
