#!/bin/bash
clear
. /etc/nyuuk/miner.var

_edit_pool(){
	if [ ! -z "$POOL" ]; then
	  echo -e "POOL default is ${G}$POOL$A"
	fi
	read -p 'input pool with port (pool:port) = ' pl
	if [ ! -z $pl ]; then
	  sed -si "s/POOL=$POOL/POOL=$pl/g" $_var
	fi
}
_edit_wallet(){
	if [ ! -z "$WALLET_VERUS" ]; then
	  echo -e "WALLET_VERUS default is $G$WALLET_VERUS$A"
	fi
	read -p 'input wallet verus = ' wl
	if [ ! -z $wl ]; then
	sed -si "s/WALLET_VERUS=$WALLET_VERUS/WALLET_VERUS=$wl/g" $_var
	fi
}
_edit_name(){
	if [ ! -z "$NAME_WORKER" ]; then
	  echo -e "NAME_WORKER default is $G$NAME_WORKER$A"
	fi
	read -p 'input name worker = ' nm
	if [ ! -z $nm ]; then
	sed -si "s/NAME_WORKER=$NAME_WORKER/NAME_WORKER=$nm/g" $_var
	fi
}
_edit_threads(){
	if [ ! -z "$THREADS" ]; then
	  echo -e "THREADS default is $G$THREADS$A"
	fi
	read -p 'input threads (only number) = ' th
	if [ ! -z $th ]; then
	sed -si "s/THREADS=$THREADS/THREADS=$th/g" $_var
	fi
}
echo -e "Welcome to Verus menu (with ccminer)"
echo -e "${R}-----------------------------------${A}"
echo -e "             ${G}List Menu${A}"
echo -e "${R}-----------------------------------${A}"
echo -e "  ${W}1.${A} ${G}Install Verus${A}"
echo -e "  ${W}2.${A} ${G}Start Verus${A}"
echo -e "  ${W}3.${A} ${G}Stop Verus${A}"
echo -e "  ${W}4.${A} ${G}Edit Pool Verus${A}"
echo -e "  ${W}5.${A} ${G}Edit Wallet Verus${A}"
echo -e "  ${W}6.${A} ${G}Edit Name for Minner${A}"
echo -e "  ${W}7.${A} ${G}Edit Threads for Minner${A}"
echo -e "  ${W}8.${A} ${G}Auto Start Verus${A}"
echo -e "${R}-----------------------------------${A}"
read -p 'select number = ' pil

case $pil in
1)
	clear
	_edit_pool;_edit_wallet;_edit_name;_edit_threads
	sleep 1; echo -e "${G}Install ccminer${A}"
	apt-get update && apt-get upgrade -y
	apt-get install -y libcurl4-openssl-dev libssl-dev libjansson-dev automake autotools-dev build-essential git screen
	mkdir /etc/nyuuk; cd /etc/nyuuk/
	git clone --single-branch -b ARM https://github.com/monkins1010/ccminer.git
	cd ccminer
	chmod +x build.sh && chmod +x configure.sh && chmod +x autogen.sh
	./build.sh
	cat <<EOF > /etc/nyuuk/ccminer/run
#!/bin/bash
. /etc/nyuuk/miner.var
cd /etc/nyuuk/minner.var
./ccminer -a verus -o stratum+tcp://\${POOL} -u \${WALLET_VERUS}_\${NAME_WORKER} -p x -t \${THREADS}
EOF
chmod +x /etc/nyuuk/ccminer/run
	cat <<EOF > /etc/systemd/system/miner-verus.service
[Unit]
Description=Minner Verus Service
Documentation=https://github.com/Nyuuk/miner
After=network.target nss-lookup.target

[Service]
User=root
ExecStart=/etc/nyuuk/ccminer/run
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now miner-verus
clear
if [ "`systemctl is-enabled miner-verus`" == 'enabled' ]; then
	echo -e "${G}miner-verus is enabled${A}"
fi
if [ "`systemctl is-active miner-verus`" == 'active' ]; then
	echo -e "${G}miner-verus is actived${A}"
fi
echo -e "${W}Installation${A} ${G}Succes${A}"
echo -e "Thank you to use this script"
echo -e "Support me Nyuuk"
echo -e "Verus Wallet ${RL}RDtKQGm9JUWUQL7XbGcED35wY6NxbRrVB4${A}"
exit
;;
2)
	_pron="[CTRL + A, D] to detach ccminer (on background)"
	if [ "`systemctl is-active miner-verus`" == 'active' ]; then
		echo -e "miner-verus is ${G}actived${A} in service systemd"
		read -p "do you want to start again (y/N) ? " trorno
		if [ "$trorno" = 'y' ] || [ "$trorno" == 'Y' ]; then
			echo -e $_pron
			clear; screen -S ver /etc/nyuuk/ccminer/run
		else
			exit
		fi
	else
    read -p 'Start with systemd (y/N) ? ' yorn
		if [ "$yorn" = 'y' ] || [ "$yorn" == 'Y' ]; then
      echo -e "Starting with ${G}SYSTEMD$A"; sleep 1
	    echo -en "${W}Checking service systemd${A}"; sleep 1
      systemctl start miner-verus.service
	    if [ `systemctl is-active miner-verus` == 'active' ];then
		    echo -e " ${G}Actived$A"
        echo -e "${G}SUCCES$A"
	    else
		    echo -e " ${R}Stoped$A"
        echo -e "Sorry starting with systemd is failed"
      fi
    else
      echo -e "Starting with ${G}SCREEN$A"
		  screen -dmS ver /etc/nyuuk/ccminer/run; sleep 1
      if [ `screen -ls|grep ver|wc -l` == '1' ]; then
        echo -e "${G}SUCCES"
      fi
    fi
	fi
;;
3)
	echo -en "${W}Checking service systemd${A}"; sleep 1
	if [ `systemctl is-active miner-verus` == 'active' ];then
		echo -e " ${G}Actived$A"
		echo -en "${W}Stop service miner-verus"; systemctl stop miner-verus
	  if [ `systemctl is-active miner-verus` == 'inactive' ];then
      echo -e " ${G}SUCCES"
	  fi
	else
		echo -e " ${R}Stoped$A"
	fi
	echo -en "${W}Checking service on SCREEN${A}"; sleep 1
		if [ -z `screen -ls|grep ver` ];then
			echo -e " ${R}Stoped$A"
	else
		echo -e " ${G}Actived$A"
		echo -e "${W}Stop service SCREEN$A"; kill `screen -ls|grep ver|cut -d '.' -f1|awk '{print $1}'`
	fi
;;
4)
	_edit_pool
;;
5)
	_edit_wallet
;;
6)
	_edit_name
;;
7)
	_edit_threads
;;
8)
	if [ `systemctl is-enabled miner-verus` == 'enabled' ]; then
		echo -e "service systemd is ${G}enabled$A"; exit
	else
		systemctl enable --now miner-verus
	fi
;;
esac
