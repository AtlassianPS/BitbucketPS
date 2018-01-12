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