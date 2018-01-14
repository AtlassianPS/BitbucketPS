function Set-ConfigServer {
    <#
    .SYNOPSIS
       Defines the configured URL for the Bitbucket server
    .DESCRIPTION
       This function defines the configured URL for the Bitbucket server that BitbucketPS should manipulate. By default, this is stored in a config.xml file at the module's root path.
    .PARAMETER Server
        Full URL to your Bitbucket server
    .PARAMETER ConfigFile
        Alternative path to your configuration file.  You must include the path and file name.
    .EXAMPLE
       Set-ConfigServer 'https://Bitbucket.example.com:8080'
       This example defines the server URL of the Bitbucket server configured in the BitbucketPS config file.
    .EXAMPLE
       Set-ConfigServer -Server 'https://Bitbucket.example.com:8080' -ConfigFile C:\Bitbucketconfig.xml
       This example defines the server URL of the Bitbucket server configured at C:\Bitbucketconfig.xml.
    .INPUTS
       This function does not accept pipeline input.
    .OUTPUTS
       [System.String]
    .NOTES
       Support for multiple configuration files is limited at this point in time, but enhancements are planned for a future update.
    #>
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        [Parameter( Mandatory )]
        [ValidateNotNullOrEmpty()]
        [Uri]$Server,

        [String]$ConfigFile
    )

    Begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    Process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        # Using a default value for this parameter wouldn't handle all cases. We want to make sure
        # that the user can pass a $null value to the ConfigFile parameter...but if it's null, we
        # want to default to the script variable just as we would if the parameter was not
        # provided at all.

        if (-not ($ConfigFile)) {
            # This file should be in $moduleRoot/Functions/Internal, so PSScriptRoot will be $moduleRoot/Functions
            $moduleFolder = Split-Path -Path $PSScriptRoot -Parent
            $ConfigFile = Join-Path -Path $moduleFolder -ChildPath 'config.xml'
        }

        Write-Debug "[$($MyInvocation.MyCommand.Name)] Config file path: $ConfigFile"
        if (-not (Test-Path -Path $ConfigFile)) {
            Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Creating new Config file"
            $xml = [XML] '<Config></Config>'
        }
        else {
            Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Using existing Config file"
            $xml = New-Object -TypeName XML
            $xml.Load($ConfigFile)
        }

        $xmlConfig = $xml.DocumentElement
        if ($xmlConfig.LocalName -ne 'Config') {
            $errorItem = [System.Management.Automation.ErrorRecord]::new(
                ([System.ArgumentException]"Invalid Document"),
                'InvalidObject.InvalidDocument',
                [System.Management.Automation.ErrorCategory]::InvalidData,
                $_
            )
            $errorItem.ErrorDetails = "Unexpected document element [$($xmlConfig.LocalName)] in configuration file. You may need to delete the config file and recreate it using this function."
            $PSCmdlet.ThrowTerminatingError($errorItem)
        }

        $fixedServer = $Server.AbsoluteUri.Trim('/')

        if ($xmlConfig.Server) {
            $xmlConfig.Server = $fixedServer
        }
        else {
            $xmlServer = $xml.CreateElement('Server')
            $xmlServer.InnerText = $fixedServer
            [void] $xmlConfig.AppendChild($xmlServer)
        }

        try {
            $xml.Save($ConfigFile)
        }
        catch {
            throw $_
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
