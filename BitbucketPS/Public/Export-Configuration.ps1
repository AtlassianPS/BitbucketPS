function Export-Configuration {
    <#
    .SYNOPSIS
        Store the server configuration to disk

    .DESCRIPTION
        This allows to store the Bitbucket Servers stored in the module's memory to disk.
        By doing this, the module will load the servers back into memory every time it is loaded.

        _Stored sessions will not be stored when exported._

    .EXAMPLE
        Set-BitbucketConfiguration -Uri "https://server.com"
        Export-BitbucketConfiguration
        --------
        Description
        Stores the server to disk.

    .LINK
        Set-Configuration
        New-Session
    #>
    [CmdletBinding()]
    param()

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        Import-MqcnAlias -Alias "ExportConfiguration" -Command "Configuration\Export-Configuration"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $export = $script:Configuration
        $export.Server = $export.Server | Select-Object -Exclude Session

        ExportConfiguration -InputObject $export
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
