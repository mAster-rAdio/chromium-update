$erroractionpreference = "stop"
$url = "https://commondatastorage.googleapis.com/chromium-browser-snapshots/"

if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
	$url += "Win_x64"
} else {
	$url += "Win"
}

$client = New-Object System.Net.WebClient
Write-Output "Querying remote version..."
$remote = $client.DownloadString($url + "/LAST_CHANGE")
write-output "Remote version is $remote"
$ood = 0

$ver = "$HOME\.chromium.version"

if (Test-Path $ver) {
	Write-Output "Querying local version..."
	$local = Get-Content $ver
	Write-Output "Local version is $local"

	if ($remote -ne $local -as [int]) {
		$ood = 1
	}
} else {
	Write-Output "No local version cache found"
	$ood = 1
}

$fname = "mini_installer.exe"

if ($ood) {
	Write-Output "Downloading remote version..."
	$client.DownloadFile($url + "/" + $remote + "/$fname", "$env:TEMP\$fname")
	Write-Output "Installing new version..."
	& "$env:TEMP\$fname"
    Wait-Process -Name ([System.IO.Path]::GetFileNameWithoutExtension($fname))
	Write-Output "Updating local version cache..."
	$remote | Set-Content $ver
}

Write-Output "Local version is up to date"

Write-Output "Removing leftover files..."
Remove-Item $env:LOCALAPPDATA\Chromium\Application\* -Recurse -Include chrome.7z
