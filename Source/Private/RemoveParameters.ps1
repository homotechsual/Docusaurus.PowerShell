<#
.SYNOPSIS
    Removes specified parameters from the PARAMETERS section of a markdown file.

.DESCRIPTION
    This function reads a markdown file and removes parameter sections matching the
    names provided in the RemoveParameters array. It identifies parameter headers
    in the format '### -ParameterName' and removes the entire parameter section
    including its description.

.PARAMETER MarkdownFile
    System.IO.FileInfo object for the markdown file

.PARAMETER RemoveParameters
    Array of parameter names to remove (with or without leading dash)
#>
function RemoveParameters {
    [CmdletBinding()]
    param(
        [System.IO.FileInfo]$MarkdownFile,
        [array]$RemoveParameters
    )

    if ($RemoveParameters.Count -eq 0) {
        return
    }

    Write-Verbose "  [x] removing parameters: $($RemoveParameters -join ', ')"

    $content = ReadFile -MarkdownFile $MarkdownFile

    # Normalize parameter names to include leading dash
    $normalizedParams = $RemoveParameters | ForEach-Object {
        if ($_ -notlike '-*') {
            "-$_"
        } else {
            $_
        }
    }

    $lines = $content -split "`n"
    $outputLines = [System.Collections.Generic.List[string]]::new()
    $skipMode = $false
    $i = 0

    while ($i -lt $lines.Count) {
        $line = $lines[$i]

        # Check if this is a parameter header we should remove
        if ($line -match '^###\s+(-\w+)') {
            $paramName = $Matches[1]
            if ($paramName -in $normalizedParams) {
                Write-Verbose "    - Removing parameter: $paramName"
                $skipMode = $true
                $i++
                continue
            }
        }

        # Check if we've reached the next section or parameter
        if ($skipMode) {
            if ($line -match '^###?\s+' -or $line -match '^##\s+') {
                # We've reached the next section, stop skipping
                $skipMode = $false
            } else {
                # Still in the parameter we're removing, skip this line
                $i++
                continue
            }
        }

        $outputLines.Add($line)
        $i++
    }

    $newContent = $outputLines -join "`n"
    WriteFile -MarkdownFile $MarkdownFile -Content $newContent
}
