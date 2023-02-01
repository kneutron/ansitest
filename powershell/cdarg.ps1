#!/usr/local/bin/pwsh

<# REF: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_switch?view=powershell-7.3 #>

$param1=$args[0]
Write-Output $param1 

# switch -Regex $(param1)
# 'bincloud|binc' {}

switch ($param1)
{
    1 {cd ~/bin/powershell }
#    2 {cd "c:\users\$env:UserName" }
#    3 {cd "c:\users\$env:UserName\Desktop\Docs-local\bin-cloud" }
    shr {cd /Volumes/zhgstera6/shrcompr-zhgst6 }
    notshr {cd /Volumes/zhgstera6/notshrcompr-zhgst6 }
    dvd {cd /Volumes/zhgstera6/dvdrips-shr/MAKEMKV }
    
    Default { Write-Output "Fallthru, no match" }
}

Get-Location  # pwd