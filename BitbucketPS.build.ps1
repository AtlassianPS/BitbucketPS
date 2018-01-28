[CmdletBinding()]
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingWriteHost', '')]
param(
    $releasePath = "$BuildRoot\Release"
)

#region Setup
$WarningPreference = "Continue"
if ($PSBoundParameters.ContainsKey('Verbose')) {
    $VerbosePreference = "Continue"
}
if ($PSBoundParameters.ContainsKey('Debug')) {
    $DebugPreference = "Continue"
}

$env:PSModulePath = "$($env:PSModulePath);$releasePath"

Set-StrictMode -Version Latest

Install-Module BuildHelpers -Scope CurrentUser
Import-Module BuildHelpers

function Get-AppVeyorBuild {
    param()

    if (-not ($env:APPVEYOR_API_TOKEN)) {
        throw "missing api token for AppVeyor."
    }
    if (-not ($env:APPVEYOR_ACCOUNT_NAME)) {
        throw "not an appveyor build."
    }

    Invoke-RestMethod -Uri "https://ci.appveyor.com/api/projects/$env:APPVEYOR_ACCOUNT_NAME/$env:APPVEYOR_PROJECT_SLUG" -Method GET -Headers @{
        "Authorization" = "Bearer $env:APPVEYOR_API_TOKEN"
        "Content-type"  = "application/json"
    }
}
function Get-TravisBuild {
    param()

    if (-not ($env:TRAVIS_API_TOKEN)) {
        throw "missing api token for Travis-CI."
    }
    if (-not ($env:APPVEYOR_ACCOUNT_NAME)) {
        throw "not an appveyor build."
    }

    Invoke-RestMethod -Uri "https://api.travis-ci.org/builds?limit=10" -Method Get -Headers @{
        "Authorization"      = "token $env:TRAVIS_API_TOKEN"
        "Travis-API-Version" = "3"
    }
}

# Synopsis: Create an initial environment for developing on the module
task SetUp InstallDependencies, Build

# Synopsis: Install all module used for the development of this module
task InstallDependencies InstallPandoc, {
    Install-Module platyPS -Scope CurrentUser -Force
    Install-Module Pester -Scope CurrentUser -Force
    Install-Module PSScriptAnalyzer -Scope CurrentUser -Force
}
#endregion Setup

#region HarmonizeVariables
switch ($true) {
    {$env:APPVEYOR_JOB_ID} {
        $CI = "AppVeyor"
        $OS = "Windows"
        continue
    }
    {$env:TRAVIS} {
        $CI = "Travis"
        $OS = $env:TRAVIS_OS_NAME
        continue
    }
    Default {
        $CI = "local"
        $OS = "Windows"
        $branch = git branch 2>&1 | select-string -Pattern "^\*\s(.+)$" | Foreach-Object { $_.Matches.Groups[1].Value}
        $commit = git log 2>&1 | select-string -Pattern "^commit ([0-9a-f]{7}) \(HEAD ->.*$branch.*$" | Foreach-Object { $_.Matches.Groups[1].Value}
        continue
    }
}

$PROJECT_NAME = if ($env:APPVEYOR_PROJECT_NAME) {$env:APPVEYOR_PROJECT_NAME} elseif ($env:TRAVIS_REPO_SLUG) {$env:TRAVIS_REPO_SLUG} else {Split-Path $BuildRoot -Leaf}
$BUILD_FOLDER = if ($env:APPVEYOR_BUILD_FOLDER) {$env:APPVEYOR_BUILD_FOLDER} elseif ($env:TRAVIS_BUILD_DIR) {$env:TRAVIS_BUILD_DIR} else {$BuildRoot}
$REPO_NAME = if ($env:APPVEYOR_REPO_NAME) {$env:APPVEYOR_REPO_NAME} elseif ($env:TRAVIS_REPO_SLUG) {$env:TRAVIS_REPO_SLUG} else {Split-Path $BuildRoot -Leaf}
$REPO_BRANCH = if ($env:APPVEYOR_REPO_BRANCH) {$env:APPVEYOR_REPO_BRANCH} elseif ($env:TRAVIS_BRANCH) {$env:TRAVIS_BRANCH} elseif ($branch) {$branch} else {''}
$REPO_COMMIT = if ($env:APPVEYOR_REPO_COMMIT) {$env:APPVEYOR_REPO_COMMIT} elseif ($env:TRAVIS_COMMIT) {$env:TRAVIS_COMMIT} elseif ($commit) {$commit} else {''}
$REPO_COMMIT_AUTHOR = if ($env:APPVEYOR_REPO_COMMIT_AUTHOR) {$env:APPVEYOR_REPO_COMMIT_AUTHOR} else {''}
$REPO_COMMIT_TIMESTAMP = if ($env:APPVEYOR_REPO_COMMIT_TIMESTAMP) {$env:APPVEYOR_REPO_COMMIT_TIMESTAMP} else {''}
$REPO_COMMIT_RANGE = if ($env:TRAVIS_COMMIT_RANGE) {$env:TRAVIS_COMMIT_RANGE} else {''}
$REPO_COMMIT_MESSAGE = if ($env:APPVEYOR_REPO_COMMIT_MESSAGE) {$env:APPVEYOR_REPO_COMMIT_MESSAGE} elseif ($env:TRAVIS_COMMIT_MESSAGE) {$env:TRAVIS_COMMIT_MESSAGE} else {''}
$REPO_COMMIT_MESSAGE_EXTENDED = if ($env:APPVEYOR_REPO_COMMIT_MESSAGE_EXTENDED) {$env:APPVEYOR_REPO_COMMIT_MESSAGE_EXTENDED} else {''}
$REPO_PULL_REQUEST_NUMBER = if ($env:APPVEYOR_PULL_REQUEST_NUMBER) {$env:APPVEYOR_PULL_REQUEST_NUMBER} elseif ($env:TRAVIS_PULL_REQUEST) {$env:TRAVIS_PULL_REQUEST} else {''}
$REPO_PULL_REQUEST_TITLE = if ($env:APPVEYOR_PULL_REQUEST_TITLE) {$env:APPVEYOR_PULL_REQUEST_TITLE} else {''}
$REPO_PULL_REQUEST_SHA = if ($env:TRAVIS_PULL_REQUEST_SHA) {$env:TRAVIS_PULL_REQUEST_SHA} else {''}
$BUILD_ID = if ($env:APPVEYOR_BUILD_ID) {$env:APPVEYOR_BUILD_ID} elseif ($env:TRAVIS_BUILD_ID) {$env:TRAVIS_BUILD_ID} else {''}
$BUILD_NUMBER = if ($env:APPVEYOR_BUILD_NUMBER) {$env:APPVEYOR_BUILD_NUMBER} elseif ($env:TRAVIS_BUILD_NUMBER) {$env:TRAVIS_BUILD_NUMBER} else {''}
$BUILD_VERSION = if ($env:APPVEYOR_BUILD_VERSION) {$env:APPVEYOR_BUILD_VERSION} elseif ($env:TRAVIS_BUILD_NUMBER) {$env:TRAVIS_BUILD_NUMBER} else {''}
$BUILD_JOB_ID = if ($env:APPVEYOR_JOB_ID) {$env:APPVEYOR_JOB_ID} elseif ($env:TRAVIS_JOB_ID) {$env:TRAVIS_JOB_ID} else {''}
$REPO_TAG = if ($env:APPVEYOR_REPO_TAG) {$env:APPVEYOR_REPO_TAG} elseif ($env:TRAVIS_TAG) {([bool]$env:TRAVIS_TAG)} else {''}
$REPO_TAG_NAME = if ($env:APPVEYOR_REPO_TAG_NAME) {$env:APPVEYOR_REPO_TAG_NAME} elseif ($env:TRAVIS_TAG) {$env:TRAVIS_TAG} else {''}
#endregion HarmonizeVariables

#region DebugInformation
task ShowDebug {
    Write-Host -Foreground "Gray"
    Write-Host ('Running in:                 {0}' -f $CI) -Foreground "Gray"
    Write-Host -Foreground "Gray"
    Write-Host ('Project name:               {0}' -f $PROJECT_NAME) -Foreground "Gray"
    Write-Host ('Project root:               {0}' -f $BUILD_FOLDER) -Foreground "Gray"
    Write-Host ('Repo name:                  {0}' -f $REPO_NAME) -Foreground "Gray"
    Write-Host ('Branch:                     {0}' -f $REPO_BRANCH) -Foreground "Gray"
    Write-Host ('Commit:                     {0}' -f $REPO_COMMIT) -Foreground "Gray"
    Write-Host ('  - Author:                 {0}' -f $REPO_COMMIT_AUTHOR) -Foreground "Gray"
    Write-Host ('  - Time:                   {0}' -f $REPO_COMMIT_TIMESTAMP) -Foreground "Gray"
    Write-Host ('  - Range:                  {0}' -f $REPO_COMMIT_RANGE) -Foreground "Gray"
    Write-Host ('  - Message:                {0}' -f $REPO_COMMIT_MESSAGE) -Foreground "Gray"
    Write-Host ('  - Extended message:       {0}' -f $REPO_COMMIT_MESSAGE_EXTENDED) -Foreground "Gray"
    Write-Host ('Pull request number:        {0}' -f $REPO_PULL_REQUEST_NUMBER) -Foreground "Gray"
    Write-Host ('Pull request title:         {0}' -f $REPO_PULL_REQUEST_TITLE) -Foreground "Gray"
    Write-Host ('Pull request SHA:           {0}' -f $REPO_PULL_REQUEST_SHA) -Foreground "Gray"
    Write-Host ('AppVeyor build ID:          {0}' -f $BUILD_ID) -Foreground "Gray"
    Write-Host ('AppVeyor build number:      {0}' -f $BUILD_NUMBER) -Foreground "Gray"
    Write-Host ('AppVeyor build version:     {0}' -f $BUILD_VERSION) -Foreground "Gray"
    Write-Host ('AppVeyor job ID:            {0}' -f $BUILD_JOB_ID) -Foreground "Gray"
    Write-Host ('Build triggered from tag?   {0}' -f $REPO_TAG) -Foreground "Gray"
    Write-Host ('  - Tag name:               {0}' -f $REPO_TAG_NAME) -Foreground "Gray"
    Write-Host -Foreground "Gray"
    Write-Host ('PowerShell version:         {0}' -f $PSVersionTable.PSVersion.ToString()) -Foreground "Gray"
    Write-Host ('OS:                         {0}' -f $OS) -Foreground "Gray"
    Write-Host ('OS Version:                 {0}' -f $PSVersionTable.BuildVersion.ToString()) -Foreground "Gray"
    Write-Host -Foreground "Gray"
}
#endregion DebugInformation

#region DependecyTasks
# Synopsis: Install pandoc to .\Tools\
task InstallPandoc -If (-not (Test-Path "$BuildRoot/Tools/pandoc.exe")) {
    # Setup
    if (-not (Test-Path "$BuildRoot/Tools")) {
        $null = New-Item -Path "$BuildRoot/Tools" -ItemType Directory
    }

    # Get latest bits
    $latestRelease = "https://github.com/jgm/pandoc/releases/download/1.19.2.1/pandoc-1.19.2.1-windows.msi"
    Invoke-WebRequest -Uri $latestRelease -OutFile "$($env:temp)\pandoc.msi"

    # Extract bits
    $null = New-Item -Path (Join-Path $env:temp 'pandoc.msi') -ItemType Directory -Force
    Start-Process -Wait -FilePath msiexec.exe -ArgumentList " /qn /a `"$(Join-Path $env:temp 'pandoc.msi')`" targetdir=`"$(Join-Path $env:temp 'pandoc/')`""

    # Move to Tools folder
    Copy-Item -Path "$($env:temp)/pandoc/Pandoc/pandoc.exe" -Destination "$BuildRoot/Tools/"
    Copy-Item -Path "$($env:temp)/pandoc/Pandoc/pandoc-citeproc.exe" -Destination "$BuildRoot/Tools/"

    # Clean
    Remove-Item -Path "$($env:temp)/pandoc" -Recurse -Force
}
#endregion DependecyTasks

#region BuildRelease
# Synopsis: Build shippable release
task Build GenerateRelease, ConvertMarkdown, UpdateManifest

# Synopsis: Generate .\Release structure
task GenerateRelease CreateHelp, {
    # Setup
    if (-not (Test-Path "$releasePath/BitbucketPS")) {
        $null = New-Item -Path "$releasePath/BitbucketPS" -ItemType Directory
    }

    # Copy module
    Copy-Item -Path "$BuildRoot/BitbucketPS/*" -Destination "$releasePath/BitbucketPS" -Recurse -Force
    # Copy additional files
    Copy-Item -Path @(
        "$BuildRoot/CHANGELOG.md"
        "$BuildRoot/LICENSE"
        "$BuildRoot/README.md"
    ) -Destination "$releasePath/BitbucketPS" -Force
    # Copy Tests
    $null = New-Item -Path "$releasePath/Tests" -ItemType Directory -ErrorAction SilentlyContinue
    Copy-Item -Path "$BuildRoot/Tests/*.ps1" -Destination "$releasePath/Tests" -Recurse -Force
    Copy-Item -Path "$BuildRoot/PSScriptAnalyzerSettings.psd1" -Destination "$releasePath" -Force
}, CompileModule

task CreateHelp {
    Install-Module platyPS -Scope CurrentUser
    Import-Module platyPS -Force
    New-ExternalHelp -Path "$BuildRoot/docs/commands" -OutputPath "$BuildRoot/BitbucketPS/en-US" -Force
    Remove-Module BitbucketPS, platyPS
}

# Synopsis: Compile all functions into the .psm1 file
task CompileModule {
    $regionsToKeep = @('Dependencies', 'ModuleConfig')

    $targetFile = "$releasePath/BitbucketPS/BitbucketPS.psm1"
    $content = Get-Content -Encoding UTF8 -LiteralPath $targetFile
    $capture = $false
    $compiled = ""

    foreach ($line in $content) {
        if ($line -match "^#region ($($regionsToKeep -join "|"))$") {
            $capture = $true
        }
        if (($capture -eq $true) -and ($line -match "^#endregion")) {
            $capture = $false
        }

        if ($capture) {
            $compiled += "$line`n"
        }
    }

    $PublicFunctions = @( Get-ChildItem -Path "$releasePath/BitbucketPS/Public/*.ps1" -ErrorAction SilentlyContinue )
    $PrivateFunctions = @( Get-ChildItem -Path "$releasePath/BitbucketPS/Private/*.ps1" -ErrorAction SilentlyContinue )

    foreach ($function in @($PublicFunctions + $PrivateFunctions)) {
        $compiled += (Get-Content -Path $function.FullName -Raw)
        $compiled += "`n"
    }

    Set-Content -LiteralPath $targetFile -Value $compiled -Encoding UTF8 -Force
    "Private", "Public" | Foreach-Object { Remove-Item -Path "$releasePath/BitbucketPS/$_" -Recurse -Force }
}

$ConvertMarkdown = @{
    # <http://johnmacfarlane.net/pandoc/>
    Inputs  = { Get-ChildItem "$releasePath/BitbucketPS/*.md" -Recurse }
    Outputs = {process {
            [System.IO.Path]::ChangeExtension($_, 'htm')
        }
    }
}
# Synopsis: Converts *.md and *.markdown files to *.htm
task ConvertMarkdown -Partial @ConvertMarkdown InstallPandoc, {process {
        exec { Tools/pandoc.exe $_ --standalone --from=markdown_github "--output=$2" }
    }
}, RemoveMarkdownFiles

# Synopsis: Update the manifest of the module
task UpdateManifest GetVersion, {
    $ModuleAlias = @(Get-Alias | Where-Object {$_.source -eq "BitbucketPS"})

    Remove-Module ConfluencePS -ErrorAction SilentlyContinue
    Import-Module "$releasePath/BitbucketPS/BitbucketPS.psd1" -Force

    Update-Metadata -Path "$releasePath/BitbucketPS/BitbucketPS.psd1" -PropertyName ModuleVersion -Value $script:Version
    # Update-Metadata -Path "$releasePath/BitbucketPS/BitbucketPS.psd1" -PropertyName FileList -Value (Get-ChildItem $BuildRoot/BitbucketPS -Recurse).Name
    if ($ModuleAlias) {
        Update-Metadata -Path "$releasePath/BitbucketPS/BitbucketPS.psd1" -PropertyName AliasesToExport -Value @($ModuleAlias.Name)
    }
    Set-ModuleFunctions -Name "$releasePath/BitbucketPS/BitbucketPS.psd1" -FunctionsToExport ([string[]](Get-ChildItem "$BuildRoot\BitbucketPS\Public\*.ps1").BaseName)
}

task GetVersion {
    $manifestContent = Get-Content -Path "$releasePath/BitbucketPS/BitbucketPS.psd1" -Raw
    if ($manifestContent -notmatch '(?<=ModuleVersion\s+=\s+'')(?<ModuleVersion>.*)(?='')') {
        throw "Module version was not found in manifest file."
    }

    $currentVersion = [Version]($Matches.ModuleVersion)
    if ($BUILD_NUMBER) {
        $newRevision = $BUILD_NUMBER
    }
    else {
        $newRevision = 0
    }
    $script:Version = New-Object -TypeName System.Version -ArgumentList $currentVersion.Major,
    $currentVersion.Minor,
    $newRevision
}
#endregion BuildRelease

#region Test
# Synopsis: Run Pester tests on the module
task Test {
    assert { Test-Path "$BuildRoot/Release/Tests/" -PathType Container }

    try {
        $result = Invoke-Pester -Script "$BuildRoot/Release/Tests/*" -PassThru -OutputFile "$BuildRoot/TestResult.xml" -OutputFormat "NUnitXml"
        if ($CI -eq "AppVeyor") {
            Add-TestResultToAppveyor -TestFile "$BuildRoot/TestResult.xml"
        }
        Remove-Item "$BuildRoot/TestResult.xml" -Force
        assert ($result.FailedCount -eq 0) "$($result.FailedCount) Pester test(s) failed."
    }
    catch {
        throw $_
    }
}
#endregion

#region Publish
function allJobsFinished {
    param()
    $buildData = Get-AppVeyorBuild
    $lastJob = ($buildData.build.jobs | Select-Object -Last 1).jobId

    if ($lastJob -ne $env:APPVEYOR_JOB_ID) {
        return $false
    }

    write-host "Waiting for other jobs to complete"

    [datetime]$stop = ([datetime]::Now).AddMinutes($env:TimeOutMins)
    [bool]$success = $false

    while (!$success -and ([datetime]::Now) -lt $stop) {
        $project = GetBuild
        $success = $true
        $project.build.jobs | foreach-object {if (($_.jobId -ne $env:APPVEYOR_JOB_ID) -and ($_.status -ne "success")) {$success = $false}; $_.jobId; $_.status}
        if (!$success) {Start-sleep 5}
    }

    if (!$success) {throw "Test jobs were not finished in $env:TimeOutMins minutes"}
}
function allCIsFinished {
    param()

    [datetime]$stop = ([datetime]::Now).AddMinutes($env:TimeOutMins)
    [bool]$success = $false

    while (!$success -and ([datetime]::Now) -lt $stop) {
        $builds = Get-TravisBuild
        $currentBuild = $builds.builds | Where-Object {$_.commit.sha -eq $env:APPVEYOR_REPO_COMMIT}
        $success = $currentBuild.state -eq "passed"
        if (!$success) {Start-sleep 5}
    }
    if (!$currentBuild) {throw "Could not get information about Travis build with sha $env:APPVEYOR_REPO_COMMIT"}
    if (!$success) {throw "Travis build did not finished in $env:TimeOutMins minutes"}
}

$shouldDeploy = (
    # only deploy from AppVeyor
    ($CI -eq "AppVeyor") -and
    # only deploy from last Job
    (allJobsFinished) -and
    # Travis must have passed as well
    (allCIsFinished) -and
    # only deploy master branch
    ($REPO_BRANCH -eq 'master') -and
    # it cannot be a PR
    (-not ($REPO_PULL_REQUEST_NUMBER)) -and
    # it cannot have a commit message that contains "skip-deploy"
    ($REPO_COMMIT_MESSAGE -notlike '*skip-deploy*')
)
task Deploy -If $shouldDeploy PublishToGallery, UpdateHomepage

task PublishToGallery {
    assert ($env:PSGalleryAPIKey) "No key for the PSGallery"

    Remove-Module BitbucketPS -ErrorAction SilentlyContinue
    Import-Module $releasePath\BitbucketPS\BitbucketPS.psd1 -ErrorAction Stop
    Publish-Module -Name BitbucketPS -NuGetApiKey $env:PSGalleryAPIKey
}

task UpdateHomepage {
    try {
        # Get the repo of the homepage
        exec { git clone https://github.com/AtlassianPS/AtlassianPS.github.io --recursive 2>&1 }
        Write-Host "Cloned"
        Set-Location "AtlassianPS.github.io/"

        # Update all submodules
        exec { git submodule foreach git pull origin master 2>&1 }
        Write-Host "Fetched"

        # Check if this repo was changed
        $status = exec { git status -s 2>&1 }
        if ($status -contains " M modules/BitbucketPS") {
            Write-Host "Has changes"
            # Update the repo in the homepage repo
            exec { git add modules/BitbucketPS 2>&1 }
            Write-Host "Added"
            exec { git commit -m "Update module BitbucketPS" 2>&1 }
            Write-Host "Commited"
            exec { git push 2>&1 }
            Write-Host "Pushed"
        }
    }
    catch {
        throw $_
    }
}
# endregion

#region Cleaning tasks
task Clean RemoveGeneratedFiles

# Synopsis: Remove generated and temp files.
task RemoveGeneratedFiles {
    $itemsToRemove = @(
        'Release'
        '*.htm'
        'TestResult.xml'
        'BitbucketPS\en-US\*'
    )
    Remove-Item $itemsToRemove -Force -Recurse -ErrorAction 0
}

task RemoveMarkdownFiles {
    Remove-Item "$releasePath\BitbucketPS\*.md" -Force -ErrorAction 0
}
# endregion

task . ShowDebug, Clean, Build, Test, Deploy
