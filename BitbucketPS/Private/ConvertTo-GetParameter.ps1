function ConvertTo-GetParameter {
    <#
    .SYNOPSIS
        Generate the GET parameter string for an URL from a hashtable
    .DESCRIPTION
        Generate the GET parameter string for an URL from a hashtable
    .EXAMPLE
        ConvertTo-GetParameter @{pageSize = 30;start=60}
        -------
        Description
        Create a http query string: ?pageSize=30&start=60
    #>
    [CmdletBinding()]
    param (
        # Key value pair that will create the query
        [Parameter( Position = 0, Mandatory = $true, ValueFromPipeline = $true )]
        [Hashtable]$InputObject
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
