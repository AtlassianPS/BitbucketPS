#region Dependencies
# Load the ConfluencePS namespace from C#
if (!("BitbucketPS.Server" -as [Type])) {
    Add-Type -Path (Join-Path $PSScriptRoot BitbucketPS.Types.cs) -ReferencedAssemblies Microsoft.CSharp, Microsoft.PowerShell.Commands.Utility, System.Management.Automation
}
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Add-Type -Path (Join-Path $PSScriptRoot BitbucketPS.Attributes.cs) -ReferencedAssemblies Microsoft.CSharp, Microsoft.PowerShell.Commands.Utility, System.Management.Automation
}

# Load Web assembly when needed
# PowerShell Core has the assembly preloaded
if (!("System.Web.HttpUtility" -as [Type])) {
    Add-Type -Assembly System.Web
}
#endregion Dependencies

#region ModuleConfig
if (
    ((Get-Variable -Name IsLinux -ErrorAction Ignore) -and $IsLinux) -or
    ((Get-Variable -Name IsMacOS -ErrorAction Ignore) -and $IsMacOS)
) {
    $fixpath = "$HOME/.local/share/" #workaround for issue#14
    Import-Module Configuration -Args @($null, $null, $null, $fixpath) -Force
}
if (Get-Command Add-MetadataConverter -Module Configuration -ErrorAction SilentlyContinue) {
    Configuration\Add-MetadataConverter @{
        [BitbucketPS.Server] = { "BitbucketPSServer @{{Name = '{0}'; Uri = '{1}'; IsCloudServer = '{2}'}}" -f $_.Name, $_.Uri, $(if ($_.IsCloudServer) {'True'} else {''}) }
        "BitbucketPSServer" = { [BitbucketPS.Server]$Args[0] }
    }
}

# Load configuration using
# https://github.com/PoshCode/Configuration
$script:Configuration = Configuration\Import-Configuration -CompanyName "AtlassianPS" -Name "BitbucketPS"
if (-not $script:Configuration.Server) {
    $script:Configuration.Server = @()
}
#endregion ModuleConfig

#region LoadFunctions
$PublicFunctions = @( Get-ChildItem -Path "$PSScriptRoot/Public/*.ps1" -ErrorAction SilentlyContinue )
$PrivateFunctions = @( Get-ChildItem -Path "$PSScriptRoot/Private/*.ps1" -ErrorAction SilentlyContinue )

# Dot source the functions
foreach ($file in @($PublicFunctions + $PrivateFunctions)) {
    try {
        . $file.FullName
    }
    catch {
        $errorItem = [System.Management.Automation.ErrorRecord]::new(
            ([System.ArgumentException]"Function not found"),
            'Load.Function',
            [System.Management.Automation.ErrorCategory]::ObjectNotFound,
            $file
        )
        $errorItem.ErrorDetails = "Failed to import function $($file.BaseName)"
        throw $errorItem
    }
}
Export-ModuleMember -Function $PublicFunctions.BaseName
#endregion LoadFunctions
