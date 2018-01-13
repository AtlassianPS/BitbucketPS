Function Get-Commit {
    [CmdletBinding(DefaultParameterSetName="All")]
    Param (
        [Parameter(Mandatory)]
        [string]$Repo,

        [Parameter(ParameterSetName="ExcludePersonal")]
        [switch]$ExcludePersonalProjects,

        [Parameter(ParameterSetName="Project")]
        [string]$Project
    )

    Validate-Session

    $ProjectKeys = Get-ProjectKey -Repo $Repo | Where { $_ -match $Project }
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

        $Uri = "/projects/$ProjectKey/repos/$Repo/commits"
        $CommitObj = Invoke-Method -Uri $Uri -Credential $Global:BBSession.Credential -Method GET
        $CommitObj | Add-Member -MemberType NoteProperty -Name Project -Value $ProjectKey
        $CommitObj | Select id,
                        displayID,
                        @{Name="Author";Expression={ $_.author.displayName }},
                        @{Name="AuthorTimeStamp";Expression={ (Get-Date "1/1/1970").AddMilliseconds($_.authorTimestamp) }},
                        @{Name="AuthorEmail";Expression={ $_.author.emailAddress }},
                        @{Name="Committer";Expression={ $_.committer.displayName }},
                        @{Name="CommitterTimeStamp";Expression={ (Get-Date "1/1/1970").AddMilliseconds($_.committerTimestamp) }},
                        Project,
                        Message
    }
}
