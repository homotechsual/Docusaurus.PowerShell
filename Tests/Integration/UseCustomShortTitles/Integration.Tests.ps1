BeforeDiscovery {
    if (-not(Get-Module Alt3.Docusaurus.Powershell)) {
        throw "Required module 'Alt3.Docusaurus.Powershell' is not loaded."
    }
}

BeforeAll {
    . "$((Get-Item -Path $PSCommandPath).Directory.Parent.FullName)/Bootstrap.ps1" -TestFolder (Get-Item -Path $PSCommandPath)
    Import-Module $test.Module -Force -DisableNameChecking -Verbose:$False -Scope Global

    # Define custom short titles for the test
    $customShortTitles = @{
        'Get-CustomTitleItem' = 'Item Retrieval'
        'Set-CustomTitleItem' = 'Item Configuration'
        # Test-ShortTitleFeature intentionally omitted to test missing mappings
    }

    # generate Docusaurus files with UseCustomShortTitles enabled
    InModuleScope Alt3.Docusaurus.Powershell -Parameters @{testModule = $test.Module; tempFolder = $test.TempFolder; titles = $customShortTitles } {
        New-DocusaurusHelp -Module $testModule -DocsFolder $tempFolder -UseCustomShortTitles -ShortTitles $titles
    }

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '', Scope='Function')]
    $generatedMdx = Get-Content -Path (Join-Path -Path $test.TempFolder -ChildPath "commands" -AdditionalChildPath "Get-CustomTitleItem.mdx")

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '', Scope='Function')]
    $expectedMdx = Get-Content (Join-Path -Path $test.Folder -ChildPath "Expected.Get-CustomTitleItem.mdx")
}

Describe "Integration test to ensure -UseCustomShortTitles and -ShortTitles customize command titles" {
    It "Mdx file generated for test should exist" {
        (Join-Path -Path $test.TempFolder -ChildPath "commands" -AdditionalChildPath "Get-CustomTitleItem.mdx") | Should -Exist
    }

    It "Mdx file generated for test should have content" {
        $generatedMdx | Should -Not -BeNullOrEmpty
    }

    It "Generated mdx should have id matching the command name" {
        $generatedMdx -join "`n" | Should -Match 'id: Get-CustomTitleItem'
    }

    It "Generated mdx should have title matching the custom short title" {
        $generatedMdx -join "`n" | Should -Match 'title: Item Retrieval'
    }

    It "Content of generated mdx file should be identical to expected fixture" {
        $generatedMdx | Should -BeExactly $expectedMdx
    }

    It "Command without custom short title should use normal command name as title" {
        $testShortTitleMdx = Get-Content -Path (Join-Path -Path $test.TempFolder -ChildPath "commands" -AdditionalChildPath "Test-ShortTitleFeature.mdx")
        $testShortTitleMdx -join "`n" | Should -Match 'title: Test-ShortTitleFeature'
    }

    It "Command without custom short title should still have correct id" {
        $testShortTitleMdx = Get-Content -Path (Join-Path -Path $test.TempFolder -ChildPath "commands" -AdditionalChildPath "Test-ShortTitleFeature.mdx")
        $testShortTitleMdx -join "`n" | Should -Match 'id: Test-ShortTitleFeature'
    }

    It "Set-CustomTitleItem should have custom short title" {
        $setMdx = Get-Content -Path (Join-Path -Path $test.TempFolder -ChildPath "commands" -AdditionalChildPath "Set-CustomTitleItem.mdx")
        $setMdx -join "`n" | Should -Match 'title: Item Configuration'
    }
}
