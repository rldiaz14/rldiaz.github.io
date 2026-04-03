param(
    [string]$ImageName = "jekyll-site",
    [string]$ContainerName = "jekyll-dev",
    [int]$Port = 4000
)

$ErrorActionPreference = "Stop"

function Get-DockerCommand {
    $dockerBinDir = "C:\Program Files\Docker\Docker\resources\bin"
    if (Test-Path $dockerBinDir) {
        if (-not (($env:Path -split ';') -contains $dockerBinDir)) {
            $env:Path = "$dockerBinDir;$env:Path"
        }
    }

    $dockerCmd = Get-Command docker -ErrorAction SilentlyContinue
    if ($dockerCmd) {
        return "docker"
    }

    $fallback = "C:\Program Files\Docker\Docker\resources\bin\docker.exe"
    if (Test-Path $fallback) {
        return $fallback
    }

    throw "Docker CLI not found. Install Docker Desktop or add docker to PATH."
}

$docker = Get-DockerCommand
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$mountPath = $projectRoot -replace "\\", "/"
$logsScriptPath = Join-Path $PSScriptRoot "logs-site.ps1"
$logsHint = if (Test-Path $logsScriptPath) { $logsScriptPath } else { "docker logs -f $ContainerName" }

Write-Host "Using project root: $projectRoot"
Write-Host "Building image: $ImageName"
& $docker build -t $ImageName $projectRoot
if ($LASTEXITCODE -ne 0) {
    throw "Docker build failed. Fix the error above and run start-site.ps1 again."
}

# Remove an old dev container if it exists.
& $docker rm -f $ContainerName 2>$null | Out-Null

Write-Host "Starting container: $ContainerName"
& $docker run -d --name $ContainerName -p "${Port}:4000" -v "${mountPath}:/usr/src/app" $ImageName | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Docker run failed. Fix the error above and run start-site.ps1 again."
}

Write-Host "Site is starting at http://localhost:$Port"
Write-Host "Tip: run '$logsHint' to tail logs."
