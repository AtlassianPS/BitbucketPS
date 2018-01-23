function Import-MqcnAlias {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory )]
        [String]
        $Alias,

        [Parameter( Mandatory )]
        [String]
        $Command
    )

    begin {
        Set-Alias -Name $Alias -Value $Command -Scope 1
    }
}
