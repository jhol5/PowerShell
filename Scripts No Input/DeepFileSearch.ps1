$search = 'cmd.exe /c'
$path = 'D:\'

$Files = Get-ChildItem -Path $path -Recurse

Foreach ($file in $Files) {
    if ($file | Get-Content | Select-String -Pattern $search) {
        $file.FullName
    }
}

