# TabExpansionPlusPlus

function ServerNameCompletion {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    Get-BitbucketConfiguration |
        Where-Object { $_.Name -like "$wordToComplete*" } |
        ForEach-Object {
            New-CompletionResult -CompletionText $_.Name
        }
}
