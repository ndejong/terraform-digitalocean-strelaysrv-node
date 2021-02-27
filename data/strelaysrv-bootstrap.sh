#!/bin/sh

# Copyright (c) 2018 Verb Networks Pty Ltd <contact [at] verbnetworks.com>
#  - All rights reserved.
#
# Apache License v2.0
#  - http://www.apache.org/licenses/LICENSE-2.0

#locale
LANG="en_US.UTF-8"
LANGUAGE="en_US:en"
LC_ALL="en_US.UTF-8"

# lockout the root account
passwd -l root

# lockdown ssh based auth
sed -i -e '/.*PasswordAuthentication/s/^.*$/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i -e '/.*PubkeyAuthentication/s/^.*$/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i -e '/.*PermitRootLogin/s/^.*$/PermitRootLogin no/' /etc/ssh/sshd_config
service ssh restart

# install packages that are helpful here
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get --yes -o DPkg::options::="--force-confold" upgrade
DEBIAN_FRONTEND=noninteractive apt-get --yes -o DPkg::options::="--force-confold" install htop iftop tree traceroute nmap tcpdump netcat figlet jq vim net-tools

# install strelaysrv and kill right away if it started via install
DEBIAN_FRONTEND=noninteractive apt-get --yes -o DPkg::options::="--force-confold" install syncthing-relaysrv
systemctl stop syncthing-relaysrv
sleep 3
killall -q strelaysrv

# disable LLMNR-resolved (Link-Local Multicast Name Resolution)
if [ -f '/etc/systemd/resolved.conf' ]; then
    sed -i -e '/^#LLMNR/s/^.*$/LLMNR=no/' /etc/systemd/resolved.conf
    systemctl restart systemd-resolved.service
fi

# insert the NAT-magic that allows us to run syncthing on a non-privileged high-port and advertise it to the world
# on some other address+port - this allows us to advertise TCP443 which is more likely to allow clients to achieve a
# full TCP connect.
if [ $(echo -n "${strelaysrv_extaddress}" | wc -c) -gt 0 ]; then

    strelaysrv_extaddress_port=$(echo "${strelaysrv_extaddress}" | tr ':' '\n' | tail -n1)

    if [ $(echo -n "$strelaysrv_extaddress_port" | wc -c) -gt 0 ]; then
        mkdir -p /etc/iptables

        # iptables for tcp4 port forwarding to tcp4-22067
        cat > /etc/iptables/strelaysrv-iptables.rules <<-EOF
					# strelaysrv-iptables.rules
					*nat
					:PREROUTING ACCEPT [18:1008]
					:INPUT ACCEPT [18:1008]
					:OUTPUT ACCEPT [0:0]
					:POSTROUTING ACCEPT [0:0]
					-A PREROUTING -i eth0 -p tcp -m tcp --dport $strelaysrv_extaddress_port -j REDIRECT --to-ports 22067
					COMMIT
				EOF

        cat > /etc/network/if-up.d/iptables <<-EOF
					#!/bin/bash
					iptables-restore < /etc/iptables/*.rules
				EOF

        chmod 755 /etc/network/if-up.d/iptables
        /etc/network/if-up.d/iptables
    fi
fi

# create a required path for keys
mkdir -p /etc/strelaysrv
chown -R syncthing:syncthing /etc/strelaysrv

# replace the exec line in /lib/systemd/system/syncthing-relaysrv.service
exec_start='/usr/bin/strelaysrv -keys="/etc/strelaysrv" -nat="false" -listen=":22067" -ext-address="${strelaysrv_extaddress}" -global-rate="${strelaysrv_globalrate}" -message-timeout="${strelaysrv_messagetimeout}" -network-timeout="${strelaysrv_networktimeout}" -per-session-rate="${strelaysrv_persessionrate}" -ping-interval="${strelaysrv_pinginterval}" -pools="${strelaysrv_pools}" -protocol="${strelaysrv_protocol}" -provided-by="${strelaysrv_providedby}" -status-srv="${strelaysrv_statussrv}"'
exec_start_escaped=$(printf '%s\n' "$exec_start" | sed -e 's/[\/&]/\\&/g')
sed -i -e "/.*ExecStart=/s/^.*$/ExecStart=$exec_start_escaped/" /lib/systemd/system/syncthing-relaysrv.service
rm -f /etc/default/syncthing-relaysrv
touch /etc/default/syncthing-relaysrv

systemctl daemon-reload
systemctl restart syncthing-relaysrv

# hostname in motd
echo -n '${hostname}' | tail -c 8 | figlet > /etc/motd
echo '' >> /etc/motd

# strelaysrv info
cat > /etc/update-motd.d/99-strelaysrv <<-EOF
	#!/bin/sh
	echo ''
	echo -n 'iptables: '
	iptables -t nat -L | grep -A2 PREROUTING | tail -n1
	echo -n 'strelaysrv: '
	/bin/journalctl -xe | /bin/grep 'relay://' | /usr/bin/tail -n1 | /usr/bin/tr ' ' '\n' | /bin/grep 'relay://'
	echo -n 'connections: '
	echo \$(netstat -anp | grep strelaysrv | grep ESTABLISHED | wc -l)
	echo 'relays: https://relays.syncthing.net/'
	echo ''
EOF
chmod 755 /etc/update-motd.d/99-strelaysrv

exit 0
