function Import-MqcnAlias {
    <#
    .SYNOPSIS
        Create an alias for a full command name

    .DESCRIPTION
        Create an alias for a full command name
        This can be used to create a mockable call to a full command name

    .EXAMPLE
        Import-MqcnAlias -Alias "GetItem" -Command Microsoft.PowerShell.Management\Get-Item
        ---------
        Description
        Create an alias "GetItem" for the normal Get-Item
    #>
    [CmdletBinding()]
    param(
        # Name of the alias to be used
        [Parameter( Mandatory )]
        [String]
        $Alias,

        # Name of the command for which to create the alias
        [Parameter( Mandatory )]
        [String]
        $Command
    )

    begin {
        Set-Alias -Name $Alias -Value $Command -Scope 1
    }
}
