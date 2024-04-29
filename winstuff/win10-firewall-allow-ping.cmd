echo PK to allow ping
echo Run as admin!
pause

netsh advfirewall firewall add rule name="ICMP Allow incoming V4 echo request" protocol=icmpv4:8,any dir=in action=allow

rem ipv6
rem netsh advfirewall firewall add rule name="ICMP Allow incoming V6 echo request" protocol=icmpv6:8,any dir=in action=allow

rem https://www.thewindowsclub.com/how-to-allow-pings-icmp-echo-requests-through-windows-firewall

rem disable:
rem netsh advfirewall firewall add rule name="ICMP Allow incoming V4 echo request" protocol=icmpv4:8,any dir=in action=block
