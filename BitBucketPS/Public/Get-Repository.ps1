Function Get-Repository {
    [CmdletBinding()]
    Param (
        [string]$Repo,

        [Parameter(ParameterSetName="ExcludePersonal")]
        [switch]$ExcludePersonalProjects
    )

    Validate-Session

    Write-Verbose "Getting Repos:"
    Write-Verbose "   RepoName: $Repo"
    Write-Verbose "     Server: $($Global:BBSession.Server)"

    $Uri = "/repos"

    $RepoObj = Invoke-Method -Uri $Uri -Credential $Global:BBSession.Credential -Method GET | Where name -match $Repo
    If ($ExcludePersonalProjects)
    {
        $RepoObj = $RepoObj | Where { -not $_.project.key.Contains("~") }
    }

    $RepoObj | Select slug,
                Name,
                State,
                StatusMessage,
                Forkable,
                @{Name="Project";Expression={ $_.project.key }},
                @{Name="ProjectName";Expression={ $_.project.name }},
                Public,
                @{Name="CloneLinks";Expression={ $_.links.clone }},
                @{Name="URL";Expression={ $_.links.self.href }}
}
