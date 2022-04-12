#!/bin/bash

# Display groups from id
if [ "$2" = "1" ]; then
  id $1 |tr ',' '\n' |sort -t\( -k 2 |paste - - |column -t
else
  id $1 |tr ',' '\n' |tr '(' ' ' |tr ')' ' '|sort -t\( -n -k 2  |column -t
fi

exit;


103       netdev                                  
108       bluetooth                               
109       lpadmin                                 
114       scanner                                 
24        cdrom                                   
25        floppy                                  
29        audio                                   
30        dip                                     
44        video                                   
46        plugdev                                 
uid=1000  user       gid=1000  user  groups=1000  user


Arg $2 = 1 output = compact and fairly easy to read, useful if a lot of groups are attached:

100(_lpoperator)                     12(everyone)                                      
204(_developer)                      250(_analyticsusers)                              
33(_appstore)                        395(com.apple.access_ftp)                         
398(com.apple.access_screensharing)  399(com.apple.access_ssh)                         
504(boinc_master)                    505(boinc_project)                                
61(localaccounts)                    701(com.apple.sharepoint.group.1)                 
702(com.apple.sharepoint.group.2)    704(com.apple.sharepoint.group.3)                 
705(com.apple.sharepoint.group.4)    79(_appserverusr)                                 
80(admin)                            81(_appserveradm)                                 
98(_lpadmin)                         uid=501(user)                      gid=20(staff)  groups=20(staff)



