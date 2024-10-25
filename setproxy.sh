# SOURCE me
#ip="192.168.1.250"
ip="192.168.1.251"

export http_proxy=http://"$ip":3128
export https_proxy=http://"$ip":3128
export ftp_proxy=http://"$ip":3128
export no_proxy=localhost
set|grep proxy=
