Function Get-BBCommits {    
    [CmdletBinding(DefaultParameterSetName="All")]
    Param (
        [Parameter(Mandatory)]
        [string]$Repo,

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
        Write-Verbose "Getting Commits:"
        Write-Verbose "   RepoName: $Repo"
        Write-Verbose " ProjectKey: $ProjectKey"
        Write-Verbose "     Server: $($Global:BBSession.Server)"

        $Uri = "$($Global:BBSession.Server)/rest/api/1.0/projects/$ProjectKey/repos/$Repo/commits"
        $CommitObj = Invoke-BBMethod -Uri $Uri -Credential $Global:BBSession.Credential -Method GET
        $CommitObj | Add-Member -MemberType NoteProperty -Name Project -Value $ProjectKey
        Write-Output $CommitObj
    }
}
