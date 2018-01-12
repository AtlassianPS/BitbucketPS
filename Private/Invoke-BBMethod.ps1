function Invoke-BBMethod
{
    #Requires -Version 3
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Get','Post','Put','Delete')]
        [String]$Method,

        [Parameter(Mandatory = $true)]
        [String]$URI,

        [ValidateNotNullOrEmpty()]
        [String]$Body,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]$Credential
    )

    $Headers = @{
        'Content-Type' = 'application/json; charset=utf-8'
    }

    #Future auth methods will go here, but for now Basic Auth
    $Token = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$($Credential.UserName):$($Credential.GetNetworkCredential().Password)"))
    $Headers.Add('Authorization', "Basic $token")

    $iwrSplat = @{
        Uri             = $Uri
        Headers         = $Headers
        Method          = $Method
        UseBasicParsing = $true
        ErrorAction     = 'Stop'

    }

    If ($Body)
    {
        # http://stackoverflow.com/questions/15290185/invoke-webrequest-issue-with-special-characters-in-json
        $cleanBody = [System.Text.Encoding]::UTF8.GetBytes($Body)
        $iwrSplat.Add('Body', $cleanBody)
    }

    If ($Session)
    {
        $iwrSplat.Add('WebSession', $session.WebSession)
    }

    #BitBucket returns paged results, let's get the pages (if there are some)
    Do {
        $webResponse = Invoke-WebRequest @iwrSplat
        $Result = $webResponse.Content | ConvertFrom-Json

        
        If (($Result | Get-Member -MemberType NoteProperty).Name -contains "isLastPage")
        {
            Write-Output $Result.values
            If ($Result.isLastPage)
            {
                Break
            }
            Else
            {
                If ($Uri.Contains("?"))
                {
                    $iwrSplat.Uri = "$($Uri)&start=$($Result.nextPageStart)"
                }
                Else
                {
                    $iwrSplat.Uri = "$($Uri)?start=$($Result.nextPageStart)"
                }
            }
        }
        Else
        {
            Write-Output $Result
            Break
        }
    } While ($true)
    write-verbose "Retrieved all data"
}


