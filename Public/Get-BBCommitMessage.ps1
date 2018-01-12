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
       
    If(!$branch){ 
    Get-Commits -credential $Credential -Repo $Repo | ft @{Name="commitId";expression={$_.displayID}},@{Name="Author";expression={$_.author.displayName}},message -Wrap
    }
    Else{
    Get-CommitsForBranch -credential $Credential -Repo $Repo -Branch $Branch | ft @{Name="commitId";expression={$_.displayID}},@{Name="Author";expression={$_.author.displayName}},message -Wrap
    }
}