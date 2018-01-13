Function New-Session {
    <#
    .Synopsis
        Creates a persistent BitBucket authenticated session which can be used by other BitBucket functions
    .DESCRIPTION
        This function creates a persistent, authenticated session in to BitBucket which can be used by all other
        BitBucketPS functions instead of explicitly passing parameters. This removes the need to use the
        -Credential parameter constantly for each function call.

        This is the equivalent of a browser cookie saving login information.

        Session data is stored in this module's PrivateData; it is not necessary to supply it to each
        subsequent function.
    .EXAMPLE
        New-BitBucketSession -Credential (Get-Credential BitBucketUsername)
        Get-BitBucketBranch
        Creates a BitBucket session for BitBucketUsername.  The following Get-BitBucketBranch is run using the
        saved session for BitBucketUsername.
    .INPUTS
        [PSCredential] The credentials to use to create the BitBucket session
    .OUTPUTS
        [BitBucketPS.Session] An object representing the BitBucket session
    #>
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
    Param(
        # Credentials to use to connect to JIRA.
        [Parameter( Mandatory )]
        [PSCredential]
        $Credential,

        [Hashtable]
        $Headers = @{}
    )

    #Read Config file, if it exists


    If (-not ($ConfigFile)) {
        $ConfigFile = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'BBconfig.xml'
    }
    If (Test-Path $ConfigFile) {
        $Xml = New-Object -TypeName XML
        $Xml.Load($ConfigFile)

        $XmlConfig = $Xml.DocumentElement
        If ($XmlConfig.LocalName -ne 'Config') {
            Write-Error "Unexpected document element [$($XmlConfig.LocalName)] in configuration file [$ConfigFile]. You may need to delete the config file and recreate it using Set-ConfigServer." -ErrorAction Stop
        }

        If ($XmlConfig.Server) {
            $Server = $XmlConfig.Server
        }
        Else {
            Write-Error "No Server element is defined in the config file.  Use Set-ConfigServer to define one." -ErrorAction Stop
        }
    }
    Else {
        Write-Error "BBconfig.XML has not been defined.  Run Set-ConfigServer" -ErrorAction Stop
    }

    Try {
        $User = Invoke-Method -URI "$Server/rest/api/latest/users/$($Credential.UserName)" -Method Get -Credential $Credential
        $Global:BBSession = [PSCustomObject]@{
            Credential = $Credential
            URI        = "$Server/rest/api/latest"
        }
        Write-Verbose "Successfully connected to BitBucket at $Server"
    }
    Catch {
        Write-Error "Unable to connect to BitBucket at $Server because ""$_""" -ErrorAction Stop
    }
}
