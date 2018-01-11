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
        'Content-Type' = 'application/json; charset=utf-8';
    }

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

    # We don't need to worry about $Credential, because it's part of the headers being sent to BitBucket
    

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


    <#
    try
    {

        Write-Debug "[Invoke-BitBucketMethod] Invoking BitBucket method $Method to URI $URI"
        $webResponse = Invoke-WebRequest @iwrSplat
    } catch {
        # Invoke-WebRequest is hard-coded to throw an exception If the Web request returns a 4xx or 5xx error.
        # This is the best workaround I can find to retrieve the actual results of the request.
        $webResponse = $_.Exception.Response
    }

    If ($webResponse)
    {
        Write-Debug "[Invoke-BitBucketMethod] Status code: $($webResponse.StatusCode)"

        If ($webResponse.StatusCode.value__ -gt 399)
        {
            Write-Warning "BitBucket returned HTTP error $($webResponse.StatusCode.value__) - $($webResponse.StatusCode)"

            # Retrieve body of HTTP response - this contains more useful information about exactly why the error
            # occurred
            $readStream = New-Object -TypeName System.IO.StreamReader -ArgumentList ($webResponse.GetResponseStream())
            $responseBody = $readStream.ReadToEnd()
            $readStream.Close()
            Write-Debug "[Invoke-BitBucketMethod] Retrieved body of HTTP response for more information about the error (`$responseBody)"
            $result = ConvertFrom-Json2 -InputObject $responseBody
        } else {
            If ($webResponse.Content)
            {
                Write-Debug "[Invoke-BitBucketMethod] Converting body of response from JSON"
                $result = ConvertFrom-Json2 -InputObject $webResponse.Content
            } else {
                Write-Debug "[Invoke-BitBucketMethod] No content was returned from BitBucket."
            }
        }

        If ($result.errors -ne $null)
        {
            Write-Debug "[Invoke-BitBucketMethod] An error response was received from BitBucket; resolving"
            Resolve-BitBucketError $result -WriteError
        } else {
            Write-Debug "[Invoke-BitBucketMethod] Outputting results from BitBucket"
            Write-Output $result
        }
    } else {
        Write-Debug "[Invoke-BitBucketMethod] No Web result object was returned from BitBucket. This is unusual!"
    }
    #>
}


