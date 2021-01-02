# get path and convert from linux path to windows path
param(
    [Parameter(Mandatory = $true, HelpMessage = "No Buildbase specified")]
    [ValidateNotNullOrEmpty()]
    [string] $Buildbase
    )

$Buildbase = wsl wslpath -w "$Buildbase"

# enable ntfs case sensitivity
fsutil.exe file setCaseSensitiveInfo "$Buildbase\android" enable
fsutil.exe file setCaseSensitiveInfo "$Buildbase\android\lineage" enable