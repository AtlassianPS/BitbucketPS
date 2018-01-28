function Get-Configuration {
    <#
    .SYNOPSIS
        Get the data of a stored server.

    .DESCRIPTION
        Retrive the stored servers.

    .EXAMPLE
        Get-Configuration
        --------
        Description
        Get all stored servers

    .EXAMPLE
        Get-Configuration -ServerName "prod"
        --------
        Description
        Get the data of the server with ServerName "prod"

    .EXAMPLE
        Get-BitbucketConfiguration -Uri "https://myserver.com"
        --------
        Description
        Get the data of the server with address "https://myserver.com"
    #>
    [CmdletBinding( DefaultParameterSetName = 'ServerData' )]
    [OutputType([BitbucketPS.Server])]
    param(
        # Address of the stored server.
        # This all wildchards.
        [Parameter( Mandatory, ParameterSetName = 'ServerDataByUri' )]
        [ArgumentCompleter(
            {
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                $command = (Get-Command -Module "BitbucketPS" -Name "Get-*Configuration").Name
                & $command |
                    Where-Object { $_.Uri -like "$wordToComplete*" } |
                    ForEach-Object { [System.Management.Automation.CompletionResult]::new( $_.Uri, $_.Uri, [System.Management.Automation.CompletionResultType]::ParameterValue, $_.Uri ) }
            }
        )]
        [Alias('Url', 'Address')]
        [Uri]
        $Uri,

        # Name of the server that was defined when stored.
        # This all wildchards.
        [Parameter( Mandatory, ValueFromPipeline, ParameterSetName = 'ServerDataByName' )]
        [ArgumentCompleter(
            {
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                $command = (Get-Command -Module "BitbucketPS" -Name "Get-*Configuration").Name
                & $command |
                    Where-Object { $_.Name -like "$wordToComplete*" } |
                    ForEach-Object { [System.Management.Automation.CompletionResult]::new( $_.Name, $_.Name, [System.Management.Automation.CompletionResultType]::ParameterValue, $_.Name ) }
            }
        )]
        [Alias('Name', 'Alias')]
        [String]
        $ServerName
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        switch ($PsCmdlet.ParameterSetName) {
            'ServerDataByName' {
                ($script:Configuration.Server | Where-Object { $_.Name -eq $ServerName })
            }
            'ServerDataByUri' {
                ($script:Configuration.Server | Where-Object { $_.Uri -eq $Uri })
            }
            'ServerData' {
                ($script:Configuration.Server)
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
