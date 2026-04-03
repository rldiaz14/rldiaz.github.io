param(
    [string]$ContainerName = "jekyll-dev",
    [int]$Tail = 100
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
& $docker logs -f --tail $Tail $ContainerName
