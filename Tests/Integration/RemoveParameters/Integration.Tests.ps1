BeforeDiscovery {
    if (-not(Get-Module Alt3.Docusaurus.Powershell)) {
        throw "Required module 'Alt3.Docusaurus.Powershell' is not loaded."
    }
}

BeforeAll {
    . "$((Get-Item -Path $PSCommandPath).Directory.Parent.FullName)/Bootstrap.ps1" -TestFolder (Get-Item -Path $PSCommandPath)
    Import-Module $test.Module -Force -DisableNameChecking -Verbose:$False -Scope Global

    # generate and read Docusaurus files in $env:Temp with -RemoveParameters
    InModuleScope Alt3.Docusaurus.Powershell -Parameters @{testModule = $test.Module; tempFolder = $test.TempFolder } {
        New-DocusaurusHelp -Module $testModule -DocsFolder $tempFolder -RemoveParameters @('-RemoveMe', '-HideMe')
    }

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '', Scope='Function')]
    $generatedMdx = Get-Content -Path $test.MdxFile

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '', Scope='Function')]
    $expectedMdx = Get-Content (Join-Path -Path $test.Folder -ChildPath "Expected.mdx")
}

Describe "Integration test to ensure -RemoveParameters filters specified parameters from documentation" {
    It "Mdx file generated for test should exist" {
        $test.MdxFile | Should -Exist
    }

    It "Mdx file generated for test should have content" {
        $generatedMdx | Should -Not -BeNullOrEmpty
    }

    It "Content of generated mdx file is identical to that of expected fixture" {
        $generatedMdx | Should -BeExactly $expectedMdx
    }

    It "Generated mdx should not contain ###  -RemoveMe parameter section" {
        $generatedMdx -join "`n" | Should -Not -Match '###\s+-RemoveMe'
    }

    It "Generated mdx should not contain ### -HideMe parameter section" {
        $generatedMdx -join "`n" | Should -Not -Match '###\s+-HideMe'
    }

    It "Generated mdx should still contain ### -KeepThisOne parameter section" {
        $generatedMdx -join "`n" | Should -Match '###\s+-KeepThisOne'
    }

    It "Generated mdx should still contain ### -AlsoKeep parameter section" {
        $generatedMdx -join "`n" | Should -Match '###\s+-AlsoKeep'
    }
}
