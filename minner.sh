#!/bin/bash

## SC BY Nyuuk ##

if [ ! -d /etc/nyuuk ]
then
	mkdir /etc/nyuuk
fi

_version='1.1'
cat <<EOF >> /etc/nyuuk/miner.var
_var=/etc/nyuuk/miner.var
W='\e[29;2m' #White
WL='\e[29;4m' #White_Garis
WM='\e[29;3m' #White_miring
R='\e[31;2m' #Red
RL='\e[31;4m' #Red_Garis
RM='\e[31;3m' #Red_miring
G='\e[32;2m' #Green
GL='\e[32;4m' #Green_Garis
GM='\e[32;3m' #Green_miring
A='\e[0m' 
EOF
. /etc/nyuuk/miner.var

clear
echo -e "${WM}Welcome to script auto Minner${A}"
echo -e "${W}Version script${A} ${GM}${_version}${A}"
echo -e "${R}-----------------------------------${A}"
echo -e "             ${G}List Menu${A}"
echo -e "${R}-----------------------------------${A}"
echo -e "  ${W}1.${A} ${G}Verus${A}"
echo -e "  ${W}2.${A} ${G}Skycoin${A}"
echo -e "${R}-----------------------------------${A}"
read -p 'select number = ' pil

case $pil in
  1)
    ./scripts/verus.sh;exit
	;;
  2)
    ./scripts/skycoin.sh;exit
	;;
esac
