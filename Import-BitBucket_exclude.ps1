$Path = "C:\Dropbox\athenaGIT\BitbucketPS"

ForEach ($FunctionType in "Public","Private")
{
    $SubPath = Join-Path -Path $Path -ChildPath $FunctionType
    Get-ChildItem $SubPath\*.ps1 | ForEach {
        . $_.FullName
    }
}

Try {
    Get-Variable BBSession -Scope Global -ErrorAction Stop
}
Catch {
    New-BBSession -Credential mpugh
    Get-Variable BBSession -Scope Global -ErrorAction Stop
}