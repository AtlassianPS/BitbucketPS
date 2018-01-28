Function Test-ServerType {
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
