## Thank you Warren http://ramblingcookiemonster.github.io/Testing-DSC-with-Pester-and-AppVeyor/

if(-not $PSScriptRoot) {
  $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}

$Verbose = @{}
if($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master") {
  $Verbose.add("Verbose", $true)
}


$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace('.Tests.', '.')
Import-Module "$PSScriptRoot\..\functions\$sut" -Force
Import-Module PSScriptAnalyzer
$Rules = (Get-ScriptAnalyzerRule)
$name = $sut.Split('.')[0]

Describe 'Script Analyzer Tests' {
  Context "Testing $name for Standard Processing" {
    foreach ($rule in $rules) {
      $index = $rules.IndexOf($rule)
      It "passes the PSScriptAnalyzer Rule number $index - $rule  " {
        (Invoke-ScriptAnalyzer -Path "$PSScriptRoot\..\functions\$sut" -IncludeRule $rule.RuleName).Count | Should Be 0 
      }
    }
  }
}

## Load the command
$ModuleBase = Split-Path -Parent $MyInvocation.MyCommand.Path

# For tests in .\Tests subdirectory
if ((Split-Path $ModuleBase -Leaf) -eq 'Tests')
{
  $ModuleBase = Split-Path $ModuleBase -Parent
}

# Handles modules in version directories
$leaf = Split-Path $ModuleBase -Leaf
$parent = Split-Path $ModuleBase -Parent
$parsedVersion = $null
if ([System.Version]::TryParse($leaf, [ref]$parsedVersion)) {
  $ModuleName = Split-Path $parent -Leaf
}
else {
  $ModuleName = $leaf
}

# Removes all versions of the module from the session before importing
Get-Module $ModuleName | Remove-Module

# Because ModuleBase includes version number, this imports the required version
# of the module
$null = Import-Module $ModuleBase\$ModuleName.psd1 -PassThru -ErrorAction Stop


## Validate functionality.

Describe "$name - JSON Data" {
  $idxfile = "$ModuleBase\bin\dbatools-buildref-index.json"
  Context 'Validate data in json is correct' {
    It "the json file is there" {
      $result = Test-Path $idxfile
      $result | Should Be $true
    }
    It "the json can be parsed" {
      $IdxRef = Get-Content $idxfile -raw | ConvertFrom-Json
      $IdxRef | Should BeOfType System.Object
    }
  }
  Context 'LastUpdated property' {
    $IdxRef = Get-Content $idxfile -raw | ConvertFrom-Json
    It "has a proper LastUpdated property" {
      $lastupdate = Get-Date -Date $IdxRef.LastUpdated
      $lastupdate | Should BeOfType System.DateTime
    }
    It "LastUpdated is updated regularly (keeps everybody on their toes)" {
      $lastupdate = Get-Date -Date $IdxRef.LastUpdated
      $lastupdate | Should BeGreaterThan (Get-Date).AddDays(-45)
    }
    It "LastUpdated is not in the future" {
      $lastupdate = Get-Date -Date $IdxRef.LastUpdated
      $lastupdate | Should BeLessThan (Get-Date)
    }
  }
  Context 'Data property' {
    $IdxRef = Get-Content $idxfile -raw | ConvertFrom-Json
    It "Data is a proper array" {
      $IdxRef.Data.Length | Should BeGreaterThan 100
    }
    It "Each Datum has a Version property" {
      $DataLength = $IdxRef.Data.Length
            $DataWithVersion = ($IdxRef.Data.Version | Where-Object { $_ }).Length
            $DataLength | Should Be $DataWithVersion
    }
        It "Each version is correctly parsable" {
            $Versions = $IdxRef.Data.Version | Where-Object { $_ }
            foreach($ver in $Versions) {
                $splitted = $ver.split('.')
                $dots = $ver.split('.').Length -1
                if ($dots -ne 2) {
                    $dots | Should Be 2
                }
                try {
                    $splitted | Foreach-Object { [convert]::ToInt32($_) }
                } catch {
                    # I know. But someone can find a method to output a custom message ?
                    $splitted -join '.' | Should Be "Composed by integers"
                }
            }
        }
        It "Versions are ordered, the way versions are ordered" {
            $Versions = $IdxRef.Data.Version | Where-Object { $_ }
            $Naturalized = $Versions | Foreach-Object {
                $splitted = $_.split('.') | Foreach-Object { [convert]::ToInt32($_) }
                "$($splitted[0].toString('00'))$($splitted[1].toString('00'))$($splitted[2].toString('0000'))"
            }
            $SortedVersions = $Naturalized | Sort
            ($SortedVersions -join ",") | Should Be ($Naturalized -join ",")
        }
        It "Names are at least 7" {
            $Names = $IdxRef.Data.Name | Where-Object { $_ }
            $Names.Length | Should BeGreaterThan 6
        }
    }
    # These are groups by major release (aka "Name")
    $IdxRef = Get-Content $idxfile -raw | ConvertFrom-Json
    $Groups = @{}
    $OrderedKeys = @()
    foreach($el in $IdxRef.Data) {
        $ver = $el.Version.split('.')[0..1] -join '.'
        if(!($Groups.ContainsKey($ver))) {
            $Groups[$ver] = New-Object System.Collections.ArrayList
            $OrderedKeys += $ver
        }
        $null = $Groups[$ver].Add($el)
    }
    foreach($g in $OrderedKeys) {
        $Versions = $Groups[$g]
        Context "Properties Check, for major release $g" {
            It "has the first element with a Name" {
                $Versions[0].Name | Should BeLike "20*"
            }
            It "No multiple Names around" {
                ($Versions.Name | Where-Object {$_}).Count | Should Be 1
            }
            It "has a single version tagged as RTM" {
                ($Versions.SP -eq 'RTM').Count | Should Be 1
            }
            It "has a single version tagged as LATEST" {
                ($Versions.SP -eq 'LATEST').Count | Should Be 1
            }
            It "SP Property is formatted correctly" {
                $Versions.SP | Where-Object {$_} | Should Match '^RTM$|^LATEST$|^SP[\d]+$'
            }
            It "CU Property is formatted correctly" {
                $CUMatch = $Versions.CU | Where-Object {$_}
                if($CUMatch) {
                    $CUMatch | Should Match '^CU[\d]+$'
                }
            }
            It "SPs are ordered correctly" {
                $SPs = $Versions.SP | Where-Object {$_}
                $SPs[0] | Should Be 'RTM'
                $SPs[-1] | Should Be 'LATEST'
                $ActualSPs = $SPs | Where {$_ -match '^SP[\d]+$'}
                $OrderedActualSPs = $ActualSPs | Sort-Object
                ($ActualSPs -join ',') | Should Be ($OrderedActualSPs -join ',')
            }
            It "LATEST is on PAR with a SP" {
                $LATEST = $Versions | Where SP -contains "LATEST"
                $LATEST.SP.Count | Should Be 2
            }
      }
    }
}
