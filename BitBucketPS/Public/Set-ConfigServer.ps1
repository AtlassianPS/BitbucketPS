Function Set-ConfigServer
{
    <#
    .Synopsis
       Defines the configured URL for the BitBucket server
    .DESCRIPTION
       This function defines the configured URL for the BitBucket server that PSBitBucket should manipulate. By default, this is stored in a config.xml file at the module's root path.
    .EXAMPLE
       Set-BitBucketConfigServer 'https://BitBucket.example.com:8080'
       This example defines the server URL of the BitBucket server configured in the PSBitBucket config file.
    .EXAMPLE
       Set-BitBucketConfigServer -Server 'https://BitBucket.example.com:8080' -ConfigFile C:\BitBucketconfig.xml
       This example defines the server URL of the BitBucket server configured at C:\BitBucketconfig.xml.
    .INPUTS
       This function does not accept pipeline input.
    .OUTPUTS
       [System.String]
    .NOTES
       Support for multiple configuration files is limited at this point in time, but enhancements are planned for a future update.
    #>
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias('Uri')]
        [String]$Server,

        [String]$ConfigFile
    )

    # Using a default value for this parameter wouldn't handle all cases. We want to make sure
    # that the user can pass a $null value to the ConfigFile parameter...but If it's null, we
    # want to default to the script variable just as we would If the parameter was not
    # provided at all.

    If (-not ($ConfigFile))
    {
        # This file should be in $moduleRoot/Functions/Internal, so PSScriptRoot will be $moduleRoot/Functions
        $ConfigFile = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'BBconfig.xml'
    }

    If (-not (Test-Path -Path $ConfigFile))
    {
        $xml = [XML] '<Config></Config>'

    }
    Else
    {
        $xml = New-Object -TypeName XML
        $xml.Load($ConfigFile)
    }

    $xmlConfig = $xml.DocumentElement
    If ($xmlConfig.LocalName -ne 'Config')
    {
        Write-Error "Unexpected document element [$($xmlConfig.LocalName)] in configuration file. You may need to delete the config file and recreate it using this function." -ErrorAction Stop
    }

    # Check for trailing slash and strip it If necessary
    $fixedServer = $Server.Trim()

    If ($fixedServer.EndsWith('/') -or $fixedServer.EndsWith('\')) {
        $fixedServer = $Server.Substring(0, $Server.Length - 1)
    }

    If ($xmlConfig.Server)
    {
        $xmlConfig.Server = $fixedServer
    }
    Else
    {
        $xmlServer = $xml.CreateElement('Server')
        $xmlServer.InnerText = $fixedServer
        [void] $xmlConfig.AppendChild($xmlServer)
    }

    Try {
        $xml.Save($ConfigFile)
    }
    Catch {
        Write-Error "Unable to save $ConfigFile because ""$_""" -ErrorAction Stop
    }
}


