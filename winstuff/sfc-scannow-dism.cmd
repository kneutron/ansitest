sfc /scannow
dism /online /cleanup-image /checkhealth
pause

dism /online /cleanup-image /scanhealth
pause

dism /online /cleanup-image /restorehealth

echo mount Win10 ISO on E:
pause

dism /online /cleanup-image /restorehealth /source:e:\sources\install.esd /limitaccess
REM skip using win updt
