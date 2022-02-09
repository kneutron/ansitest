
 rem to have Win updates use Squid - Win7
Netsh winhttp import proxy source=ie
pause
s
@echo off
 rem Win8 syntax:
 rem netsh winhttp import proxy source=ie

 rem to reset proxy settings:
 rem Netsh winhttp reset proxy
 rem http://answers.oreilly.com/topic/1391-how-to-configure-windows-update-to-use-a-proxy-server/
