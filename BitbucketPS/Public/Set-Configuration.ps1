function Set-Configuration {
    <#
    .SYNOPSIS
        Stores Bitbucket Server object for the module to known with what server it should talk to.

    .DESCRIPTION
        This function allows for several Bitbucket Server object to be stored in memory.
        Stored servers are used by the commands in order to know with what Bitbucket server to communicate.

        The stored servers can be exported to file with `Export-BitbucketConfiguration`.
        _Exported servers will be imported automatically when the module is loaded._

    .EXAMPLE
        Set-BitbucketConfiguration -Uri "https://server.com/" -ServerName "Server Prod"
        -----------
        Description
        This command will store the server address and name in memory and allow other commands
        to identify the server by the name "Server Prod"

    .LINK
        Export-Configuration
    #>
    [CmdletBinding( SupportsShouldProcess = $false )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        # Address of the Bitbucket Server.
        [Parameter( Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName )]
        [Alias('Url', 'Address')]
        [Uri]
        $Uri,

        # Name with which this server will be stored.
        # If no name is provided, the "Authority" of the addess will be used.
        # This value must be unique. In case the ServerName was already saved,
        # it will be overwritten.
        #
        # Example for "Authority":
        #   https://www.google.com/maps?hl=en --> "www.google.com"
        [Parameter( ValueFromPipelineByPropertyName )]
        [Alias('Name', 'Alias')]
        [String]
        $ServerName = $Uri.Authority,

        # Stores a WebSession to the server object.
        [Microsoft.PowerShell.Commands.WebRequestSession]
        $Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        if (-not ($script:Configuration.Server)) {
            $script:Configuration.Server = @()
        }
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $config = [BitbucketPS.Server]@{
            Name          = $ServerName
            Uri           = $Uri
            Session       = $Session
            IsCloudServer = (Test-ServerIsCloud -Uri $Uri -ErrorAction Stop)
        }

        $newConfiguration = @()
        foreach ($server in $script:Configuration.Server) {
            if ($server.Name -ne $config.Name) {
                $newConfiguration += $server
            }
            else {
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Removing server `$server: $($server.Name)"
            }
        }
        $script:Configuration.Server = $newConfiguration

        Write-Debug "[$($MyInvocation.MyCommand.Name)] Adding server `$config: $($config.Name)"
        $script:Configuration.Server += $config
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
