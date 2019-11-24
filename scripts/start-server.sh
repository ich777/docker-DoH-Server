#!/bin/bash
CUR_V="$(find ${DATA_DIR} -name dohinstalled-* | cut -d '-' -f 2,3)"
LAT_V="$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/m13253/dns-over-https/tags | jq -r '.[0].name' | cut -c2-)"
if [ "${DoH-V}" == "latest" ]; then
	DoH-V=$LAT_V
fi
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "---Checking if DoH-Server is installed---"
if [ ! -f ${DATA_DIR}/doh-server/doh-server ]; then
	echo "---DoH-Server not installed, installing---"
    cd ${DATA_DIR}
    if wget ${GO_DL_URL} ; then
		echo "---Sucessfully downloaded Golang---"
    else
		echo "---Something went wrong, can't download Golang, putting server in sleep mode---"
		sleep infinity
    fi
    tar xzf go*
    export GOROOT=/DoH/go
    export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
    if [ ! -d ${DATA_DIR}/gopath ]; then
    	mkdir gopath
    fi
    export GOPATH=/DoH/gopath/
	if wget https://github.com/m13253/dns-over-https/archive/v${DoH_V}.tar.gz ; then
    	echo "---Sucessfully downloaded DoH---"
    else
    	echo "---Something went wrong, can't download DoH, putting server in sleep mode---"
        sleep infinity
    fi
	tar xzf v${DoH_V}.tar.gz
	touch dohinstalled-${DoH_V}
    CUR_V=${DoH_V}
	rm *.tar.gz
	cd ${DATA_DIR}/dns-over-https-${DoH_V}
	make
	mv ${DATA_DIR}/dns-over-https-${DoH_V}/doh-server/ ${DATA_DIR}
	rm ${DATA_DIR}/doh-server/doh-server.conf
	cd ${DATA_DIR}
	rm -R ${DATA_DIR}/dns-over-https-${DoH_V} ${DATA_DIR}/go ${DATA_DIR}/gopath
else
	echo "---DoH-Server found!---"
fi

echo "---Version Check---"
if [ "${DoH_V}" != "$CUR_V" ]; then
	echo "---Version missmatch v${CUR_V} installed, installing v${DoH_V}---"
    rm ${DATA_DIR}/dohinstalled-${CUR_V}
	cd ${DATA_DIR}
    if wget ${GO_DL_URL} ; then
		echo "---Sucessfully downloaded Golang---"
    else
		echo "---Something went wrong, can't download Golang, putting server in sleep mode---"
		sleep infinity
    fi
    tar xzf go*
    export GOROOT=/DoH/go
    export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
    if [ ! -d ${DATA_DIR}/gopath ]; then
    	mkdir gopath
    fi
    export GOPATH=/DoH/gopath/
	if wget https://github.com/m13253/dns-over-https/archive/v${DoH_V}.tar.gz ; then
    	echo "---Sucessfully downloaded DoH---"
    else
    	echo "---Something went wrong, can't download DoH, putting server in sleep mode---"
        sleep infinity
    fi
	tar xzf v${DoH_V}.tar.gz
	touch dohinstalled-${DoH_V}
	rm *.tar.gz
	cd ${DATA_DIR}/dns-over-https-${DoH_V}
	make
    rm -R ${DATA_DIR}/doh-server
	mv ${DATA_DIR}/dns-over-https-${DoH_V}/doh-server/ ${DATA_DIR}
	rm ${DATA_DIR}/doh-server/doh-server.conf
	cd ${DATA_DIR}
	rm -R ${DATA_DIR}/dns-over-https-${DoH_V} ${DATA_DIR}/go ${DATA_DIR}/gopath
elif [ "${DoH_V}" == "$CUR_V" ]; then
	echo "---Versions match! Installed: v$CUR_V | Preferred: v${DoH_V}---"
fi

if [ "$(echo ${DoH_V} | sed -e 's/\.//g')" -ge "220" ]; then
	if [ ! -f ${DATA_DIR}/doh-server.conf ]; then
		cd ${DATA_DIR}
		if wget -qO doh-server.conf "https://raw.githubusercontent.com/ich777/docker-DoH/master/config/doh-server-2.2.0.conf" --show-progress ; then
        	echo "---Sucessfully downloaded configuration file 'doh-server.conf' located in the root directory of the container---"
		else
			echo "---Something went wrong, can't download 'doh-server.conf', putting server in sleep mode---"
			sleep infinity
		fi     
    else
    	if grep -rq 'tcp_only = ' ${DATA_DIR}/doh-server.conf; then
        	echo "---You got an old configuration file, downloading new config file---"
            cd ${DATA_DIR}
			if wget -qO doh-server-new.conf "https://raw.githubusercontent.com/ich777/docker-DoH/master/config/doh-server-2.2.0.conf" --show-progress ; then
				echo "---Sucessfully downloaded configuration file 'doh-server-new.conf' located in the root directory of the container---"
			else
				echo "---Something went wrong, can't download 'doh-server-new.conf', putting server in sleep mode---"
				sleep infinity
			fi
            chmod 770 ${DATA_DIR}/doh-server-new.conf
            echo "-------------------------------------------------------------------------"
            echo "-----New configuration file downloaded, please check your server dir!----"
            echo "---Delete the old 'doh-server.conf' and edit the 'doh-server-new.conf'---"
            echo "---to your preferred settings and rename it to 'doh-server.conf' then----"
            echo "---------restart the container! Putting server into sleep mode!----------"
            echo "-------------------------------------------------------------------------"
            sleep infinity
		fi
	fi
else
	if [ ! -f ${DATA_DIR}/doh-server.conf ]; then
		cd ${DATA_DIR}
		if wget -qO doh-server.conf "https://raw.githubusercontent.com/ich777/docker-DoH/master/config/doh-server-2.1.9.conf" --show-progress ; then
			echo "---Sucessfully downloaded configuration file 'doh-server.conf' located in the root directory of the container---"
		else
			echo "---Something went wrong, can't download 'doh-server.conf', putting server in sleep mode---"
			sleep infinity
		fi
	else
    	if grep -rq 'tcp_only = ' ${DATA_DIR}/doh-server.conf ; then
        	echo
        else
        	echo "-------------------------------------------------------------------"
        	echo "-----You got a new configuration file and an old server version----"
            echo "---Please change the version number to greater or equal to 2.2.0---"
            echo "---or delete the 'doh-server.conf' file and restart the container--"
            echo "------------------Putting server into sleep mode!------------------"
            echo "-------------------------------------------------------------------"
            sleep infinity
		fi
	fi
fi

echo "---Preparing Server---"
find ${DATA_DIR} -name ".*" -exec rm -R -f {} \;
chmod -R 777 ${DATA_DIR}

echo "---Starting Server---"
cd ${DATA_DIR}/doh-server
${DATA_DIR}/doh-server/doh-server -conf ${DATA_DIR}/doh-server.conf