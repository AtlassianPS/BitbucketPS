function Get-CommitMessage {    
[CmdletBinding()]
param (
    [PSCredential]$credential, 
    [string]$branch, 
    [string]$Repo
)


Write-Verbose "
    Getting Commit Messages:
    RepoName: $Repo
    Server: $Server
    "
If(!$branch){ 
Get-Commits -credential $Credential -Repo $Repo | ft @{Name="commitId";expression={$_.displayID}},@{Name="Author";expression={$_.author.displayName}},message -Wrap
}
Else{
Get-CommitsForBranch -credential $Credential -Repo $Repo -Branch $Branch | ft @{Name="commitId";expression={$_.displayID}},@{Name="Author";expression={$_.author.displayName}},message -Wrap
}


}