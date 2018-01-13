Function New-BBSession
{
    <#
    .SYNOPSIS
        Simple helper script to store server location and credential in a varialbe.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [PSCredential]$Credential,

        [String]$ConfigFile
    )

    #Read Config file, if it exists


    If (-not ($ConfigFile))
    {
        $ConfigFile = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'BBconfig.xml'
    }
    If (Test-Path $ConfigFile)
    {
        $Xml = New-Object -TypeName XML
        $Xml.Load($ConfigFile)

        $XmlConfig = $Xml.DocumentElement
        If ($XmlConfig.LocalName -ne 'Config')
        {
            Write-Error "Unexpected document element [$($XmlConfig.LocalName)] in configuration file [$ConfigFile]. You may need to delete the config file and recreate it using Set-BBConfigServer." -ErrorAction Stop
        }

        If ($XmlConfig.Server)
        {
            $Server = $XmlConfig.Server
        } 
        Else 
        {
            Write-Error "No Server element is defined in the config file.  Use Set-BBConfigServer to define one." -ErrorAction Stop
        }
    }
    Else
    {
        Write-Error "BBconfig.XML has not been defined.  Run Set-BBConfigServer" -ErrorAction Stop
    }

    Try {
        $User = Invoke-BBMethod -URI "$Server/rest/api/latest/users/$($Credential.UserName)" -Method Get -Credential $Credential
        $Global:BBSession = [PSCustomObject]@{
            Credential   = $Credential
            URI          = "$Server/rest/api/latest"
        }
        Write-Verbose "Successfully connected to BitBucket at $Server"
    }
    Catch {
        Write-Error "Unable to connect to BitBucket at $Server because ""$_""" -ErrorAction Stop
    }
}
