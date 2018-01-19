function New-Session {
    <#
    .Synopsis
        Creates a persistent BitBucket authenticated session which can be used by other BitBucket functions

    .DESCRIPTION
        This function creates a persistent, authenticated session into BitBucket which can be used by all other
        BitBucketPS functions instead of explicitly passing parameters. This removes the need to use the
        -Credential parameter constantly for each function call.

        This is the equivalent of a browser cookie saving login information.

    .EXAMPLE
        New-BitBucketSession -ServerName "myServer" -Credential (Get-Credential BitBucketUsername)
        --------
        Description
        Creates a BitBucket session for the user "BitBucketUsername" and associates it with the "myServer" server.

    .Link
        Get-Configuration
    .Link
        Set-Configuration
    #>
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
    Param(
        # Name with which to identified the Bitbucket Server.
        #
        # In case no server was stored, use Set-BitbucketConfiguration.
        # In case the name is not know, use Get-BitbucketConfiguration.
        [Parameter( Mandatory )]
        [String]
        $ServerName,

        # Credentials to use to connect to Server.
        [Parameter( Mandatory )]
        [PSCredential]
        $Credential,

        [Hashtable]
        $Headers = @{}
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $resourceURi = "/projects"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $iwParameters = @{
            Uri             = $resourceURi
            ServerName      = $ServerName
            Method          = "Get"
            Headers         = $Headers
            SessionVariable = "thisSession"
            Credential      = $Credential
        }
        if (Invoke-Method @iwParameters) {
            Set-Configuration -Uri (Get-Configuration -ServerName $ServerName -ErrorAction Stop).Uri -ServerName $ServerName -Session $thisSession
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
