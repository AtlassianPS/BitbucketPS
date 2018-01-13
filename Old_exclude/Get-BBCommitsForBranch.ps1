Function Get-BBCommitsForBranch {    
[CmdletBinding()]
param (
    [string]$Branch, 
    [string]$Repo
)

    
    $ProjectKeys = Get-BBProjectKey -repo $Repo 

    ForEach ($ProjectKey in $ProjectKeys)
    {
        Write-Verbose "
        Getting Commits:
        RepoName: $Repo
        ProjectKey: $ProjectKey
        Server: $Server
        "

        $uri = "$($Global:BBsession.Server)/rest/api/1.0/projects/$ProjectKey/repos/$Repo/commits/?until=$Branch"

        Invoke-BBMethod -uri $uri -credential $Global:BBsession.Credential -method GET
    }
}

Get-BBCommitsForBranch -Repo wincfg -branch Feature/PSPDEVO-89-create-docker-image-registry