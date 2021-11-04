#!/bin/bash
clear
. /etc/nyuuk/miner.var

_edit_pool(){
	read -p 'input pool with port (pool:port) = ' pl
	echo -e "POOL=$pl" >> $_var
}
_edit_wallet(){
	read -p 'input wallet verus = ' wl
	echo -e "WALLET_VERUS=$wl" >> $_var
}
_edit_name(){
	read -p 'input name worker = ' nm
	echo -e "NAME_WORKER=$nm" >> $_var
}
_edit_threads(){
	read -p 'input threads (only number) = ' th
	echo -e "THREADS=$th" >> $_var
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
	fi
	sleep 1; echo -e "${G}Install ccminer${A}"
	apt-get update && apt-get upgrade -y
	apt-get install -y libcurl4-openssl-dev libssl-dev libjansson-dev automake autotools-dev build-essential git screen
	mkdir /etc/nyuuk; cd /etc/nyuuk/
	git clone - -single-branch -b ARM https://github.com/monkins1010/ccminer.git
	cd ccminer
	chmod +x build.sh && chmod +x configure.sh && chmod +x autogen.sh
	./build.sh
	cat <<EOF > /etc/nyuuk/ccminer/run
#!/bin/bash
. /etc/nyuuk/miner.var
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
	_pron=`echo -e "[CTRL + A, D] to detach ccminer (on background)"`
	if [ "`systemctl is-active miner-verus`" == 'active' ]; then
		echo -e "miner-verus is ${G}actived${A} in service systemd"
		read -p "do you want to start again (y/N) ? " trorno
		if [ "$trorno" = 'y' ] || [ "$trorno" == 'Y']; then
			$_pron
			clear; screen -dmS ver /etc/nyuuk/ccminer/run
		else
			exit
		fi
	else
		_pron
		screen -dmS ver /etc/nyuuk/ccminer/run
	fi
;;
3)
	echo -en "${W}Checking service systemd${A}"; sleep 1
	if [ `systemctl is-active miner-verus` == 'active' ];
		echo -e "${G}Actived$A"
		echo -e "${W}Stop service miner-verus"; systemctl stop miner-verus
	else
		echo -e "${R}Stoped$A"
	fi
	echo -en "${W}Checking service on SCREEN${A}"; sleep 1
		if [ -z `screen -ls|grep ver` ];
			echo -e "${R}Stoped$A"
	else
		echo -e "${G}Actived$A"
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
