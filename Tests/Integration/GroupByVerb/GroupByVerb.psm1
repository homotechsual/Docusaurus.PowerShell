[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Scope = "Function")]
param()

function Get-TestItem {
<#
    .SYNOPSIS
        Gets a test item.

    .DESCRIPTION
        This function tests the GroupByVerb parameter with a Get verb.

    .PARAMETER Name
        The name of the item to get.

    .EXAMPLE
        Get-TestItem -Name "test"

        Gets an item named "test".
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Name
    )

    Write-Output "Getting item: $Name"
}

function Set-TestItem {
<#
    .SYNOPSIS
        Sets a test item.

    .DESCRIPTION
        This function tests the GroupByVerb parameter with a Set verb.

    .PARAMETER Name
        The name of the item to set.

    .PARAMETER Value
        The value to set.

    .EXAMPLE
        Set-TestItem -Name "test" -Value "value"

        Sets an item with a value.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [string]$Value
    )

    Write-Output "Setting item: $Name = $Value"
}

function Test-GroupByVerb {
<#
    .SYNOPSIS
        Tests the GroupByVerb functionality.

    .DESCRIPTION
        This function tests the GroupByVerb parameter with a Test verb.

    .PARAMETER Condition
        A condition to test.

    .EXAMPLE
        Test-GroupByVerb -Condition "true"

        Tests a condition.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Condition
    )

    Write-Output "Testing condition: $Condition"
}
