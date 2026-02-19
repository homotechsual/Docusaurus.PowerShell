BeforeDiscovery {
    if (-not(Get-Module Alt3.Docusaurus.Powershell)) {
        throw "Required module 'Alt3.Docusaurus.Powershell' is not loaded."
    }
}

BeforeAll {
    # Setup paths for this test
    $testFolder = Get-Item -Path $PSCommandPath
    $testName = $testFolder.Directory.Name
    $cachedMarkdownPath = Join-Path -Path $testFolder.Directory.FullName -ChildPath "CachedMarkdown"
    $test = @{
        Name = $testName
        Folder = $testFolder.Directory
        TempFolder = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "Alt3.Docusaurus.Powershell" |
            Join-Path -ChildPath $testName
        MdxFile = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "Alt3.Docusaurus.Powershell" |
            Join-Path -ChildPath $testName |
            Join-Path -ChildPath "commands" |
            Join-Path -ChildPath "Test-CachedMarkdown.mdx"
        CachedMarkdownPath = $cachedMarkdownPath
    }

    # remove any previous folders in $env:Temp
    if ((Get-Module Alt3.Docusaurus.Powershell) -and (Test-Path -Path $test.TempFolder)) {
        Remove-Item $test.TempFolder -Recurse -Force
    }

    # generate Docusaurus files using cached PlatyPS markdown
    InModuleScope Alt3.Docusaurus.Powershell -Parameters @{cachedPath = $test.CachedMarkdownPath; tempFolder = $test.TempFolder } {
        New-DocusaurusHelp -PlatyPSMarkdownPath $cachedPath -DocsFolder $tempFolder
    }

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '', Scope='Function')]
    $generatedMdx = Get-Content -Path $test.MdxFile

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '', Scope='Function')]
    $expectedMdx = Get-Content (Join-Path -Path $test.Folder -ChildPath "Expected.mdx")
}

Describe "Integration test to ensure -PlatyPSMarkdownPath processes cached markdown files" {
    It "Mdx file generated for test should exist" {
        $test.MdxFile | Should -Exist
    }

    It "Mdx file generated for test should have content" {
        $generatedMdx | Should -Not -BeNullOrEmpty
    }

    It "Cached markdown source file should exist" {
        Join-Path -Path $test.CachedMarkdownPath -ChildPath "Test-CachedMarkdown.md" | Should -Exist
    }

    It "Generated mdx should contain MODULE NAME from cached markdown" {
        $generatedMdx -join "`n" | Should -Match "Test function for PlatyPSMarkdownPath parameter"
    }

    It "Content of generated mdx file is identical to that of expected fixture" {
        $generatedMdx | Should -BeExactly $expectedMdx
    }
}
