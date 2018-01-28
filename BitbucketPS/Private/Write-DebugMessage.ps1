function Write-DebugMessage {
    <#
    .SYNOPSIS
        Write a message to the debug stream without creating a breakpoint

    .DESCRIPTION
        Write a message to the debug stream without creating a breakpoint

    .EXAMPLE
        Write-DebugMessage "The value of `$var is: $var"
        ----------
        Description
        Shows the message if the user added `-Debug` to the command but does not create a breakpoint
    #>
    [CmdletBinding()]
    param(
        # Message to print
        [Parameter( ValueFromPipeline )]
        [String]
        $Message
    )

    begin {
        $oldDebugPreference = $DebugPreference
        if (-not ($DebugPreference -eq "SilentlyContinue")) {
            $DebugPreference = 'Continue'
        }
    }

    process {
        Write-Debug $Message
    }

    end {
        $DebugPreference = $oldDebugPreference
    }
}
