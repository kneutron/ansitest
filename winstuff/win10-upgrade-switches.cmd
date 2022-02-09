@echo off
REM Use when upgrading win10 major versions, 2004 to 20H1 etc
REM MAKE A FULL BARE-METAL BACKUP before running this

REM Assumes the presence of drive D: to copy files to (remove "/Tempdrive D" if necessary)

REM Borrowed from: https://www.itninja.com/question/script-for-determining-the-drive-letter-of-the-cd-on-windows-pe-2-1
set tagfile=\setup.exe
for %%i in (d e f g h i j k l m n o p q r s t u v w x y z) do if exist "%%i:%tagfile%" set DVD=%%i
%DVD%:\setup /Auto Upgrade /CompactOS Enable /DynamicUpdate disable /EULA accept /MigNEO disable /ShowOOBE none /Telemetry disable /Tempdrive D /Uninstall disable 
