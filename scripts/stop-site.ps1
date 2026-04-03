param(
    [string]$ContainerName = "jekyll-dev"
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

& $docker rm -f $ContainerName 2>$null | Out-Null
Write-Host "Stopped and removed container: $ContainerName"
