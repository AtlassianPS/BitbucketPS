function Remove-Configuration {
    <#
    .SYNOPSIS
        Remove a Stores Bitbucket Server from memory.

    .DESCRIPTION
        This function allows for several Bitbucket Server object to be removed in memory.

    .EXAMPLE
        Remove-BitbucketConfiguration -ServerName "Server Prod"
        -----------
        Description
        This command will remove the server identified as "Server Prod" from memory.

    .LINK
        Export-Configuration
    #>
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        # Name with which this server is stored.
        [Parameter( Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName )]
        [ArgumentCompleter(
            {
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                $commandName = (Get-Command -Module "BitbucketPS" -Name "Get-*Configuration").Name
                & $commandName |
                    Where-Object { $_.$parameterName -like "$wordToComplete*" } |
                    ForEach-Object { [System.Management.Automation.CompletionResult]::new( $_.$parameterName, $_.$parameterName, [System.Management.Automation.CompletionResultType]::ParameterValue, $_.$parameterName ) }
            }
        )]
        [Alias('Name', 'Alias')]
        [String]
        $ServerName
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $trackRemoval = $false
        $newConfiguration = @()
        foreach ($server in $script:Configuration.Server) {
            if ($server.Name -ne $ServerName) {
                $newConfiguration += $server
            }
            else {
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Removing server `$server: $($server.Name)"
                $trackRemoval = $true
            }
        }

        if ($trackRemoval) {
            $script:Configuration.Server = $newConfiguration
        }
        else {
            $errorItem = [System.Management.Automation.ErrorRecord]::new(
                ([System.ArgumentException]"Object Not Found"),
                "ServerType.UnknownType",
                [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                $ServerName
            )
            $errorItem.ErrorDetails = "No server '$ServerName' could be found."
            $PSCmdlet.WriteError($errorItem)
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
