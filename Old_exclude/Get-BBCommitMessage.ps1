Function Get-BBCommitMessage {    
    [CmdletBinding(DefaultParameterSetName="All")]
    Param (
        [Parameter(Mandatory)]
        [string]$Repo,

        [Parameter(ParameterSetName="ExcludePersonal")]
        [switch]$ExcludePersonalProjects,

        [Parameter(ParameterSetName="Project")]
        [string]$Project
    )

    Write-Verbose "Getting Commit Messages:"
    Write-Verbose "   RepoName: $Repo"
    Write-Verbose "     Server: $Server"

    $BBCommitsSplat = @{
        Repo = $Repo
    }
    If ($ExcludePersonalProjects)
    {
        $BBCommitsSplat.Add("ExcludePersonalProjects",$true)
    }
    If ($Project)
    {
        $BBCommitsSplat.Add("Project",$Project)
    }
       
    Get-BBCommits @BBCommitsSplat | Select @{Name="commitId";Expression={ $_.displayID }},@{Name="Author";Expression={ $_.author.displayName }},@{Name="TimeStamp";Expression={ (Get-Date "1/1/1970").AddMilliseconds($_.committerTimestamp) }},Project,Message 
}
