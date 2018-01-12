Function Get-BBBranch {    
    [CmdletBinding(DefaultParameterSetName="All")]
    Param (
        [Parameter(Mandatory)]
        [string]$Repo,

        [string]$Branch,

        [Parameter(ParameterSetName="ExcludePersonal")]
        [switch]$ExcludePersonalProjects,

        [Parameter(ParameterSetName="Project")]
        [string]$Project
    )

    ValidateBBSession

    $ProjectKeys = Get-BBProjectKey -Repo $Repo | Where { $_ -match $Project }
    If ($ExcludePersonalProjects)
    {
        $ProjectKeys = $ProjectKeys | Where { -not $_.Contains("~") }
    }

    ForEach ($ProjectKey in $ProjectKeys)
    {
        Write-Verbose "Getting Branches:"
        Write-Verbose "         Repo: $Repo"
        Write-Verbose "   ProjectKey: $ProjectKey"
        Write-Verbose "       Server: $($Global:BBSession.Server)"

        $Uri = "$($Global:BBSession.Server)/rest/api/1.0/projects/$ProjectKey/repos/$Repo/branches"
        $Branches = Invoke-BBMethod -Uri $uri -Credential $Global:BBSession.Credential -Method GET | Where displayId -match $Branch

        $Branches | Add-Member -MemberType NoteProperty -Name Project -Value $ProjectKey
        Write-Output $Branches
    }
}
