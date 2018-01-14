Function Get-Branch {
    <#
    .SYNOPSIS
        Get branch information from a designated repository
    .PARAMETER Repo
        Name or partial name of the repository you want to query
    .PARAMETER Branch
        Name or partial name of the branch you want to query
    .PARAMETER ExcludePersonalProjects
        If multiple forks of a repository exist, Get-Branch will show them all.  Use this parameter to exclude those.
    .PARAMETER Project
        If multiple forks of a repository exist you can use this filter to limit which projects you want to see.
    .INPUTS
        None
    .OUTPUTS
        [PSCustomObject]
    .EXAMPLE
        Get-Branch -Repo BitbucketPS

        This will show all of the branchs, from all forks of any repository with that matches BitbucketPS.

    .EXAMPLE
        Get-Branch -Repo BitbucketPS -Branch dev

        Same as first example, but will limit output to branches that match dev
    .EXAMPLE
        Get-Branch -Repo BitbucketPS -ExcludePersonalProjects

        This will limit the output to branches that are not in peoples personal projects.
    .EXAMPLE
        Get-Branch -Repo BitbucketPS -Project ~

        This would limit the output to only personal projects.
    .NOTES
    .LINK
    #>
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

    Validate-Session

    $ProjectKeys = Get-ProjectKey -Repo $Repo | Where { $_ -match $Project }
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

        $Uri = "/projects/$ProjectKey/repos/$Repo/branches"
        $Branches = Invoke-Method -Uri $uri -Credential $Global:BBSession.Credential -Method GET | Where displayId -match $Branch

        $Branches | Add-Member -MemberType NoteProperty -Name Project -Value $ProjectKey
        $Branches
    }
}
