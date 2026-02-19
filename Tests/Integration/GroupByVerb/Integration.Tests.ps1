BeforeDiscovery {
    if (-not(Get-Module Alt3.Docusaurus.Powershell)) {
        throw "Required module 'Alt3.Docusaurus.Powershell' is not loaded."
    }
}

BeforeAll {
    . "$((Get-Item -Path $PSCommandPath).Directory.Parent.FullName)/Bootstrap.ps1" -TestFolder (Get-Item -Path $PSCommandPath)
    Import-Module $test.Module -Force -DisableNameChecking -Verbose:$False -Scope Global

    # generate Docusaurus files using -GroupByVerb
    InModuleScope Alt3.Docusaurus.Powershell -Parameters @{testModule = $test.Module; tempFolder = $test.TempFolder } {
        New-DocusaurusHelp -Module $testModule -DocsFolder $tempFolder -GroupByVerb
    }

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '', Scope='Function')]
    $commandsFolder = Join-Path -Path $test.TempFolder -ChildPath "commands"

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '', Scope='Function')]
    $getFolder = Join-Path -Path $commandsFolder -ChildPath "Get"

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '', Scope='Function')]
    $setFolder = Join-Path -Path $commandsFolder -ChildPath "Set"

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '', Scope='Function')]
    $testFolder = Join-Path -Path $commandsFolder -ChildPath "Test"

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '', Scope='Function')]
    $getTestItemFile = Join-Path -Path $getFolder -ChildPath "Get-TestItem.mdx"

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '', Scope='Function')]
    $setTestItemFile = Join-Path -Path $setFolder -ChildPath "Set-TestItem.mdx"

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '', Scope='Function')]
    $testGroupByVerbFile = Join-Path -Path $testFolder -ChildPath "Test-GroupByVerb.mdx"
}

Describe "Integration test to ensure -GroupByVerb organizes commands into verb-based folders" {
    It "Commands folder should exist" {
        $commandsFolder | Should -Exist
    }

    It "Get verb subfolder should exist" {
        $getFolder | Should -Exist
    }

    It "Set verb subfolder should exist" {
        $setFolder | Should -Exist
    }

    It "Test verb subfolder should exist" {
        $testFolder | Should -Exist
    }

    It "Get-TestItem.mdx should exist in Get subfolder" {
        $getTestItemFile | Should -Exist
    }

    It "Set-TestItem.mdx should exist in Set subfolder" {
        $setTestItemFile | Should -Exist
    }

    It "Test-GroupByVerb.mdx should exist in Test subfolder" {
        $testGroupByVerbFile | Should -Exist
    }

    It "Get-TestItem.mdx should have content" {
        Get-Content $getTestItemFile | Should -Not -BeNullOrEmpty
    }

    It "Set-TestItem.mdx should have content" {
        Get-Content $setTestItemFile | Should -Not -BeNullOrEmpty
    }

    It "Test-GroupByVerb.mdx should have content" {
        Get-Content $testGroupByVerbFile | Should -Not -BeNullOrEmpty
    }

    It "Get-TestItem.mdx should contain correct synopsis" {
        (Get-Content $getTestItemFile -Raw) | Should -Match "Gets a test item"
    }

    It "Set-TestItem.mdx should contain correct synopsis" {
        (Get-Content $setTestItemFile -Raw) | Should -Match "Sets a test item"
    }

    It "Test-GroupByVerb.mdx should contain correct synopsis" {
        (Get-Content $testGroupByVerbFile -Raw) | Should -Match "Tests the GroupByVerb functionality"
    }

    It "Commands should NOT be in the root commands folder" {
        Get-ChildItem -Path $commandsFolder -Filter "*.mdx" -File | Should -BeNullOrEmpty
    }
}
