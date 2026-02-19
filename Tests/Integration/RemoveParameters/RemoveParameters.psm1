[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Scope = "Function")]
param()

function Test-RemoveParameters {
<#
    .SYNOPSIS
        Dummy module to test the -RemoveParameters switch

    .DESCRIPTION
        This function has multiple parameters including some that will be filtered out.

    .PARAMETER KeepThisOne
        This parameter should remain in the documentation.

    .PARAMETER RemoveMe
        This parameter should be removed from the documentation.

    .PARAMETER AlsoKeep
        Another parameter that should remain in the documentation.

    .PARAMETER HideMe
        This parameter should be removed from the documentation.

    .EXAMPLE
        Test-RemoveParameters -KeepThisOne "test" -AlsoKeep "value"

        This example shows basic usage.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$KeepThisOne,

        [Parameter(Mandatory = $false)]
        [string]$RemoveMe,

        [Parameter(Mandatory = $false)]
        [string]$AlsoKeep,

        [Parameter(Mandatory = $false)]
        [string]$HideMe
    )

    Write-Output "Testing RemoveParameters"
}
