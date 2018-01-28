Function Test-ServerIsCloud {
    <#
    .SYNOPSIS
        Test if a Bitbucket URL is a cloud server or a "on-premise" server

    .DESCRIPTION
        This tests if a URL is a valid Bitbucket server and of what kind

    .EXAMPLE
        Test-ServerIsCloud -Uri "http://myserver.com"
        --------
        Description
        Will return true, if the url is a bitbucket cloud server
        Will return false, if the url is a bitbucket server
        Will throw an error, if the url is not a bitbucket server
    #>
    [CmdletBinding()]
    [OutputType([Bool])]
    Param (
        # Address of the Server to be tested
        [Parameter( Mandatory )]
        [Uri]
        $Uri,

        # Additional headers
        [Hashtable]
        $Headers,

        # Parameter that defines the original caller of this function
        # This is used so that errors can be thrown on the level the user called it
        # instead of showing cryptic lines of code of the guts of functions
        #
        # Please do not use this parameter unless you know what you are doing.
        $Caller = $PSCmdlet
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        # pass input to local variable
        # this allows to use the PSBoundParameters for recursion
        $_headers = @{}
        $Headers.Keys.foreach( { $_headers[$_] = $Headers[$_] })
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        # load DefaultParameters for Invoke-WebRequest
        # as the global PSDefaultParameterValues is not used
        $PSDefaultParameterValues = $global:PSDefaultParameterValues

        $response = Invoke-WebRequest -Uri $Uri -Headers $_headers

        if ($response.Headers["X-ASEN"]) {
            $false
        }
        elseif ($response.Headers["x-b3-spanid"]) {
            $true
        }
        else {
            $errorItem = [System.Management.Automation.ErrorRecord]::new(
                ([System.ArgumentException]"Unknown Server Type"),
                "ServerType.UnknownType",
                [System.Management.Automation.ErrorCategory]::InvalidResult,
                $response
            )
            $errorItem.ErrorDetails = "The server could not be identified as a Bitbucket Server."
            $Caller.WriteTerminatingError($errorItem)
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
