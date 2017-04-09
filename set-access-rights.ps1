param (
    [string]$from = "C:\Share",
    [string]$to
    )

if (!$to)
{
    $to = (Get-Item -Path ".\" -Verbose).FullName
}

Write-Host "Setting acl rights from" $from "to all files and folders in" $to

$acl = Get-Acl $from
$files = Get-ChildItem $to -recurse
foreach ($file in $files) { 
    Write-Host "`t" $file
    Set-Acl $file.FullName $acl
}

Write-Host "Done."
