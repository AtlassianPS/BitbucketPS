#Requires -Modules Pester

<#
    .SYNOPSIS
        Collection of helper functions for Pester tests
#>

#region defineVars
$script:ShowMockData = $false
$script:ShowDebugText = $false
# These variables can be used in the pester script to control
# how much debugging data should be printed to the console.
# Here is an example how to use it in a pester script:
    <#
    . "$PSScriptRoot/Shared.ps1"
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '', Scope = '*', Target = 'ShowMockData')]
    $script:ShowMockData = $true
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '', Scope = '*', Target = 'ShowDebugText')]
    $script:ShowDebugText = $false
    #>
#endregion defineVars

function defProp {
    <#
    .SYNOPSIS
        Generate an 'It' assetion that the property has the expected value
    .EXAMPLE
        $object = (ps)[0]
        Context 'Foo' {
            defProp $object 'ProcessName' 'powershell'
        }
    #>
    .SYNOPSIS

    #>
    param($obj, $propName, $propValue)
    It "Defines the '$propName' property" {
        $obj.$propName | Should Be $propValue
    }
}

function hasProp {
    <#
    .SYNOPSIS
        Generate an 'It' assetion that the object has the expected property
    .EXAMPLE
        $object = (ps)[0]
        Context 'Foo' {
            hasProp $object 'ProcessName'
        }
    #>
    param($obj, $propName)
    It "Defines the '$propName' property" {
        $obj | Get-Member -MemberType *Property -Name $propName | Should Not BeNullOrEmpty
    }
}

function hasNotProp {
    <#
    .SYNOPSIS
        Generate an 'It' assetion that the object does not have the expected property
    .EXAMPLE
        $object = (ps)[0]
        Context 'Foo' {
            hasNotProp $object 'Size'
        }
    #>
    param($obj, $propName)
    It "Defines the '$propName' property" {
        $obj | Get-Member -MemberType *Property -Name $propName | Should BeNullOrEmpty
    }
}

function defParam {
    <#
    .SYNOPSIS
        Generate an 'It' assetion that the command accepts the expected parameter
    .EXAMPLE
        $command = Get-Command "Get-Item"
        Context 'Foo' {
            defParam $object 'Path'
        }
    #>
    param($command, $name)
    It "Has a -$name parameter" {
        $command.Parameters.Item($name) | Should Not BeNullOrEmpty
    }
}

function defAlias {
    <#
    .SYNOPSIS
        Generate an 'It' assetion that the parameter accepts the expect alias
    .EXAMPLE
        $command = Get-Command "Get-Item"
        Context 'Foo' {
            defAlias $command 'LiteralPath' 'PSPath'
        }
    #>
    param($command, $name, $definition)
    It "Supports the $name alias for the $definition parameter" {
        $command.Parameters.Item($definition).Aliases | Where-Object -FilterScript {$_ -eq $name} | Should Not BeNullOrEmpty
    }
}

# This function must be used from within an It block
function checkType {
    <#
    .SYNOPSIS
        Assetion that an object is of a specific type
    .DESCRIPTION
        This assertion looks into the object's array of TypeNames.
        This is a "hack" in case the type we are looking for is not primary.
        If the object should be an instance of a specific class, use this instead:
        `$object | Should BeOfType [Namespace.Class]`
    .EXAMPLE
        $object = (ps)[0]
        Context 'Foo' {
            It 'Is of type [System.Diagnostics.Process]' {
                checkType $object 'System.Diagnostics.Process'
            }
            It 'Is of type [System.Object]' {
                checkType $object 'System.Object'
            }
        }
    #>
    param($obj, $typeName)
    if ($obj -is [System.Array]) {
        $o = $obj[0]
    }
    else {
        $o = $obj
    }

    $o.PSObject.TypeNames -contains $typeName | Should Be $true
}

function castsToString {
    <#
    .SYNOPSIS
        Assetion that an object has a string representation
    .EXAMPLE
        $object = (ps)[0]
        Context 'Foo' {
            It 'prints as string' {
                castsToString $object
            }
        }
    #>
    param($obj)
    if ($obj -is [System.Array]) {
        $o = $obj[0]
    }
    else {
        $o = $obj
    }

    $o.ToString() | Should Not BeNullOrEmpty
}

function checkPsType {
    <#
    .SYNOPSIS
        Generate 'It' assetions that ensures the object is of the
        expected type and that is has a string representation
    .EXAMPLE
        $object = (ps)[0]
        Context 'Foo' {
            checkPsType $object 'System.Diagnostics.Process'
        }
    #>
    param($obj, $typeName)
    It "Uses output type of '$typeName'" {
        checkType $obj $typeName
    }
    It "Can cast to string" {
        castsToString($obj)
    }
}

function ShowMockInfo {
    <#
    .SYNOPSIS
        Helps debugging by printing the values of parameters with which a function was called
    .DESCRIPTION
        It is recommended to use this in a mocked function, so that `$script:ShowMockData` can
        control if this should print debug data or not.
    .EXAMPLE
        Mock Get-Something {
            ShowMockInfo 'Get-Something' 'InputObject'
            Write-Output $InputObject
        }
    #>
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingWriteHost', '')]
    param(
        $functionName,
        [String[]] $params
    )
    if ($script:ShowMockData) {
        #TODO
        Write-Host "       Mocked $functionName" -ForegroundColor Cyan
        foreach ($p in $params) {
            Write-Host "         [$p]  $(Get-Variable -Name $p -ValueOnly -ErrorAction SilentlyContinue)" -ForegroundColor Cyan
        }
    }
}

Mock "Write-Debug" {
    <#
    .SYNOPSIS
        Helps debugging by printing the values of parameters with which a function was called
    #>
    MockedDebug $Message
}

function MockedDebug {
    <#
    .SYNOPSIS
        Writes debug messages to the console
    .DESCRIPTION
        It is recommended to use this in a mocked function, so that `$script:ShowDebugText` can
        control if this should print debug data or not.
        In case `Mock "Write-Debug"` is declared, the pester test can write debug messages from
        the function that is being tested in the console
    .EXAMPLE
        Mock Get-Something {
            MockedDebug ($script:PrivateVariable | Out-String)
            Write-Output $script:PrivateVariable
        }
    #>
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingWriteHost', '')]
    [CmdletBinding()]
    param(
        [String]$Message
    )
    if ($script:ShowDebugText) {
        Write-Host "       [DEBUG] $Message" -ForegroundColor Yellow
    }
}
