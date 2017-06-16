function Get-CommitsForBranch {    
[CmdletBinding()]
param (
    [PSCredential]$credential, 
    [string]$Branch, 
    [string]$Repo
)

    $server = Get-BitbucketConfigServer
    $ProjectKey = Get-ProjectKey -repo $Repo -credential $credential

    Write-Verbose "
    Getting Commits:
    RepoName: $Repo
    ProjectKey: $ProjectKey
    Server: $Server
    "

    $uri = "$server/rest/api/1.0/projects/$ProjectKey/repos/$Repo/commits/?until=$Branch"

    $Commits = Invoke-BitBucketMethod -uri $uri -credential $credential -method GET
    return $Commits.values
}
