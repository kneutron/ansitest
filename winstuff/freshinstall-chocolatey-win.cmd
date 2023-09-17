@echo RUN AS ADMIN
pause

choco install -y firefox
choco install -y chromium
choco install -y ublockorigin-chrome
rem choco install -y brave

choco install -y chocolatey-core.extension
choco install -y chocolateygui

rem Editors
choco install -y notepadplusplus.install
choco install -y vscode
choco install -y vscode-powershell 
choco install -y libreoffice-fresh
choco install -y vim

rem Utils
choco install -y crystaldiskinfo
choco install -y 7zip.install
choco install -y sysinternals

choco install -y totalcommander
choco install -y doublecmd

choco install -y powertoys
choco install -y cpu-z.install

choco install -y imagemagick.app
choco install -y fsviewer
choco install -y irfanview

rem backup
choco install -y defraggler
choco install -y veeam-agent
choco install -y rclone
choco install -y smartmontools
choco install -y gsmartcontrol

choco install -y wget
choco install -y curl
choco install -y teracopy

choco install -y mobaxterm
choco install -y kitty
choco install -y putty.install
choco install -y winscp.install
choco install -y smartftp

choco install -y microsoft-windows-terminal
choco install -y conemu
choco install -y powershell-core
choco install -y ripgrep
choco install -y wsl2

choco install -y rufus
choco install -y imgburn
choco install -y poweriso

choco install -y vlc
choco install -y handbrake.install
choco install -y makemkv

rem choco install -y adwcleaner

rem choco install -y virtualbox
rem choco install -y squid

choco list
mkdir c:\temp

rem choco export >$HOME\choco-installed.txt
choco export --output-file-path="'c:\temp\chocolatey-packages.config'" --include-version-numbers

@pause
