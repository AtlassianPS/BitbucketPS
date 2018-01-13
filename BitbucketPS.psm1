function ConvertFrom-Json2
{
	[CmdletBinding()]
	param
	(
	    [parameter(ParameterSetName = 'object', ValueFromPipeline = $true, Position = 0, Mandatory = $true)]
	    [string]$InputObject,

	    [parameter(ParameterSetName = 'object', ValueFromPipeline = $true, Position = 1, Mandatory = $false)]
	    [int]$MaxJsonLength = [int]::MaxValue
	)

	process
	{
		function PopulateJsonFrom-Dictionary
		{
			param
			(
			    [System.Collections.Generic.IDictionary`2[String,Object]]$InputObject
			)

			process
			{
				$returnObject = New-Object PSObject

				foreach($key in $InputObject.Keys)
				{
					$pairObjectValue = $InputObject[$key]

					if ($pairObjectValue -is [System.Collections.Generic.IDictionary`2].MakeGenericType([String],[Object]))
					{
						$pairObjectValue = PopulateJsonFrom-Dictionary $pairObjectValue
					}
					elseif ($pairObjectValue -is [System.Collections.Generic.ICollection`1].MakeGenericType([Object]))
					{
						$pairObjectValue = PopulateJsonFrom-Collection $pairObjectValue
					}

					$returnObject | Add-Member Noteproperty $key $pairObjectValue
				}

				return $returnObject
			}
		}

		function PopulateJsonFrom-Collection
		{
			param
			(
			    [System.Collections.Generic.ICollection`1[Object]]$InputObject
			)

			process
			{
				$returnList = New-Object ([System.Collections.Generic.List`1].MakeGenericType([Object]))
				foreach($jsonObject in $InputObject)
				{
					$jsonObjectValue = $jsonObject

					if ($jsonObjectValue -is [System.Collections.Generic.IDictionary`2].MakeGenericType([String],[Object]))
					{
						$jsonObjectValue = PopulateJsonFrom-Dictionary $jsonObjectValue
					}
					elseif ($jsonObjectValue -is [System.Collections.Generic.ICollection`1].MakeGenericType([Object]))
					{
						$jsonObjectValue = PopulateJsonFrom-Collection $jsonObjectValue
					}

					$returnList.Add($jsonObjectValue) | Out-Null
				}

				return $returnList.ToArray()
			}
		}


		$scriptAssembly = [System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")

		$typeResolver = "public class JsonObjectTypeResolver : System.Web.Script.Serialization.JavaScriptTypeResolver
						  {
						    public override System.Type ResolveType(string id)
						    {
						      return typeof (System.Collections.Generic.Dictionary<string, object>);
						    }

						    public override string ResolveTypeId(System.Type type)
						    {
						      return string.Empty;
						    }
						  }"

		Add-Type -TypeDefinition $typeResolver -ReferencedAssemblies $scriptAssembly.FullName
	    $jsonserial = New-Object System.Web.Script.Serialization.JavaScriptSerializer(New-Object JsonObjectTypeResolver)

	    $jsonserial.MaxJsonLength = $MaxJsonLength

	    $jsonTree = $jsonserial.DeserializeObject($InputObject)

		if ($jsonTree -is [System.Collections.Generic.IDictionary`2].MakeGenericType([String],[Object]))
		{
			$jsonTree = PopulateJsonFrom-Dictionary $jsonTree
		}
		elseif ($jsonTree -is [System.Collections.Generic.ICollection`1].MakeGenericType([Object]))
		{
			$jsonTree = PopulateJsonFrom-Collection $jsonTree
		}

		return $jsonTree
	}
}

function Invoke-BBMethod
{
    #Requires -Version 3
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Get','Post','Put','Delete')]
        [String]$Method,

        [Parameter(Mandatory = $true)]
        [String]$URI,

        [ValidateNotNullOrEmpty()]
        [String]$Body,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]$Credential
    )

    $Headers = @{
        'Content-Type' = 'application/json; charset=utf-8'
    }

    #Future auth methods will go here, but for now Basic Auth
    $Token = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$($Credential.UserName):$($Credential.GetNetworkCredential().Password)"))
    $Headers.Add('Authorization', "Basic $token")

    $Uri = "$($BBSession.URI)$Uri"
    $iwrSplat = @{
        Uri             = $Uri
        Headers         = $Headers
        Method          = $Method
        UseBasicParsing = $true
        ErrorAction     = 'Stop'

    }

    If ($Body)
    {
        # http://stackoverflow.com/questions/15290185/invoke-webrequest-issue-with-special-characters-in-json
        $cleanBody = [System.Text.Encoding]::UTF8.GetBytes($Body)
        $iwrSplat.Add('Body', $cleanBody)
    }

    If ($Session)
    {
        $iwrSplat.Add('WebSession', $session.WebSession)
    }

    #BitBucket returns paged results, let's get the pages (if there are some)
    Do {
        Try {
            $webResponse = Invoke-WebRequest @iwrSplat
        }
        Catch {
            Write-Error "Unable to process query because ""$_""" -ErrorAction Stop
        }
        $Result = $webResponse.Content | ConvertFrom-Json2

        
        If (($Result | Get-Member -MemberType NoteProperty).Name -contains "isLastPage")
        {
            Write-Output $Result.values
            If ($Result.isLastPage)
            {
                Break
            }
            Else
            {
                If ($Uri.Contains("?"))
                {
                    $iwrSplat.Uri = "$($Uri)&start=$($Result.nextPageStart)"
                }
                Else
                {
                    $iwrSplat.Uri = "$($Uri)?start=$($Result.nextPageStart)"
                }
            }
        }
        Else
        {
            Write-Output $Result
            Break
        }
    } While ($true)
}

Function ValidateBBSession
{
    [CmdletBinding()]
    Param ()

    Try {
        $null = Get-Variable -Name BBSession
    }
    Catch {
        Write-Error "You are not currently connected to a BitBucket server.  Run New-BBSession." -ErrorAction Stop
    }
}
Function Get-BBBranch {    
    [CmdletBinding(DefaultParameterSetName="All")]
    Param (
        [Parameter(Mandatory)]
        [string]$Repo,

        [string]$Branch,

        [Parameter(ParameterSetName="ExcludePersonal")]
        [switch]$ExcludePersonalProjects,

        [Parameter(ParameterSetName="Project")]
        [string]$Project
    )

    ValidateBBSession

    $ProjectKeys = Get-BBProjectKey -Repo $Repo | Where { $_ -match $Project }
    If ($ExcludePersonalProjects)
    {
        $ProjectKeys = $ProjectKeys | Where { -not $_.Contains("~") }
    }

    ForEach ($ProjectKey in $ProjectKeys)
    {
        Write-Verbose "Getting Branches:"
        Write-Verbose "         Repo: $Repo"
        Write-Verbose "   ProjectKey: $ProjectKey"
        Write-Verbose "       Server: $($Global:BBSession.Server)"

        $Uri = "/projects/$ProjectKey/repos/$Repo/branches"
        $Branches = Invoke-BBMethod -Uri $uri -Credential $Global:BBSession.Credential -Method GET | Where displayId -match $Branch

        $Branches | Add-Member -MemberType NoteProperty -Name Project -Value $ProjectKey
        $Branches
    }
}

Function Get-BBCommits {    
    [CmdletBinding(DefaultParameterSetName="All")]
    Param (
        [Parameter(Mandatory)]
        [string]$Repo,

        [Parameter(ParameterSetName="ExcludePersonal")]
        [switch]$ExcludePersonalProjects,

        [Parameter(ParameterSetName="Project")]
        [string]$Project
    )

    ValidateBBSession
    
    $ProjectKeys = Get-BBProjectKey -Repo $Repo | Where { $_ -match $Project }
    If ($ExcludePersonalProjects)
    {
        $ProjectKeys = $ProjectKeys | Where { -not $_.Contains("~") }
    }

    ForEach ($ProjectKey in $ProjectKeys)
    {
        Write-Verbose "Getting Commits:"
        Write-Verbose "   RepoName: $Repo"
        Write-Verbose " ProjectKey: $ProjectKey"
        Write-Verbose "     Server: $($Global:BBSession.Server)"

        $Uri = "/projects/$ProjectKey/repos/$Repo/commits"
        $CommitObj = Invoke-BBMethod -Uri $Uri -Credential $Global:BBSession.Credential -Method GET
        $CommitObj | Add-Member -MemberType NoteProperty -Name Project -Value $ProjectKey
        $CommitObj | Select id,
                        displayID,
                        @{Name="Author";Expression={ $_.author.displayName }},
                        @{Name="AuthorTimeStamp";Expression={ (Get-Date "1/1/1970").AddMilliseconds($_.authorTimestamp) }},
                        @{Name="AuthorEmail";Expression={ $_.author.emailAddress }},
                        @{Name="Committer";Expression={ $_.committer.displayName }},
                        @{Name="CommitterTimeStamp";Expression={ (Get-Date "1/1/1970").AddMilliseconds($_.committerTimestamp) }},
                        Project,
                        Message 
    }
}

Function Get-BBProjectKey {    
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$Repo
    )

    ValidateBBSession

    Write-Verbose "Getting Project Key of:"
    Write-Verbose "   RepoName: $Repo"
    Write-Verbose "     Server: $($Global:BBSession.Server)"

    Get-BBRepositories | Where-Object slug -match $Repo | Select -ExpandProperty Project
}
Function Get-BBRepositories {    
    [CmdletBinding()]
    Param (
        [string]$Repo,

        [Parameter(ParameterSetName="ExcludePersonal")]
        [switch]$ExcludePersonalProjects
    )

    ValidateBBSession
   
    Write-Verbose "Getting Repos:"
    Write-Verbose "   RepoName: $Repo"
    Write-Verbose "     Server: $($Global:BBSession.Server)"

    $Uri = "/repos"

    $RepoObj = Invoke-BBMethod -Uri $Uri -Credential $Global:BBSession.Credential -Method GET | Where name -match $Repo
    If ($ExcludePersonalProjects)
    {
        $RepoObj = $RepoObj | Where { -not $_.project.key.Contains("~") }
    }

    $RepoObj | Select slug,
                Name,
                State,
                StatusMessage,
                Forkable,
                @{Name="Project";Expression={ $_.project.key }},
                @{Name="ProjectName";Expression={ $_.project.name }},
                Public,
                @{Name="CloneLinks";Expression={ $_.links.clone }},
                @{Name="URL";Expression={ $_.links.self.href }}
}

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

Function Set-BBConfigServer
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



