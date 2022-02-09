REM run as Administrator - turn off atime on NTFS filesystems
fsutil behavior set disablelastaccess 1
echo Reboot to commit
pause
