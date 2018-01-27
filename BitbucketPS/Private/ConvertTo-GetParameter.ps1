function ConvertTo-GetParameter {
    <#
    .SYNOPSIS
    Generate the GET parameter string for an URL from a hashtable
    #>
    [CmdletBinding()]
    param (
        [Parameter( Position = 0, Mandatory = $true, ValueFromPipeline = $true )]
        [hashtable]$InputObject
    )

    begin {
        [string]$parameters = "?"
    }

    process {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Making HTTP get parameter string out of a hashtable"
        foreach ($key in $InputObject.Keys) {
            $parameters += "$key=$($InputObject[$key])&"
        }
    }

    end {
        $parameters -replace ".$"
    }
}
