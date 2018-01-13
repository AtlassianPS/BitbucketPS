Function Validate-Session
{
    [CmdletBinding()]
    Param ()

    Try {
        $null = Get-Variable -Name BBSession
    }
    Catch {
        Write-Error "You are not currently connected to a BitBucket server.  Run New-Session." -ErrorAction Stop
    }
}
