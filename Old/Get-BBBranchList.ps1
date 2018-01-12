Function Get-BBBranchList {    
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$Repo
    )

    ValidateBBSession

    $ProjectKeys = Get-BBProjectKey -Repo $Repo
    ForEach ($ProjectKey in $ProjectKeys)
    {
        Write-Verbose "Getting Branches:"
        Write-Verbose "         Repo: $Repo"
        Write-Verbose "   ProjectKey: $ProjectKey"
        Write-Verbose "       Server: $($Global:BBSession.Server)"

        $Uri = "$($Global:BBSession.Server)/rest/api/1.0/projects/$ProjectKey/repos/$Repo/branches"
        $Branches = Invoke-BBMethod -Uri $uri -Credential $Global:BBSession.Credential -Method GET

        $Branches | Add-Member -MemberType NoteProperty -Name Project -Value $ProjectKey
        Write-Output $Branches
    }
}
