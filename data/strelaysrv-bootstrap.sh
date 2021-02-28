#!/bin/sh

# Copyright (c) 2021 Verb Networks Pty Ltd <contact [at] verbnetworks.com>
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
DEBIAN_FRONTEND=noninteractive apt-get --assume-yes -o DPkg::options::="--force-confold" upgrade
DEBIAN_FRONTEND=noninteractive apt-get --assume-yes -o DPkg::options::="--force-confold" install iptables-persistent net-tools jq figlet traceroute tcpdump netcat nmap iftop htop vim tree

# determine the required release tag
if [ "${strelaysrv_release}" = "latest" ]; then
    strelaysrv_release=$(curl -s 'https://api.github.com/repos/syncthing/relaysrv/releases/latest' | jq -r .tag_name)
fi

# install the strelaysrv package and make sure it is not running post install
strelaysrv_package_url=$(curl -s 'https://api.github.com/repos/syncthing/relaysrv/releases' | jq -r .[].assets[].browser_download_url | grep "$strelaysrv_release" | grep 'amd64.deb')
wget -o /dev/null -O /tmp/strelaysrv.deb "$strelaysrv_package_url"
dpkg --install /tmp/strelaysrv.deb
sleep 1
systemctl stop strelaysrv
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
        cat > /etc/iptables/rules.v4 <<-EOF
					# strelaysrv-iptables.rules
					*nat
					:PREROUTING ACCEPT [0:0]
					:INPUT ACCEPT [0:0]
					:OUTPUT ACCEPT [0:0]
					:POSTROUTING ACCEPT [0:0]
					-A PREROUTING -i eth0 -p tcp -m tcp --dport $strelaysrv_extaddress_port -j REDIRECT --to-ports 22067
					COMMIT
				EOF

				iptables-restore < /etc/iptables/rules.v4
    fi
fi

# replace the exec line in /lib/systemd/system/strelaysrv.service
exec_start='/usr/bin/strelaysrv -nat="false" -listen=":22067" -ext-address="${strelaysrv_extaddress}" -global-rate="${strelaysrv_globalrate}" -message-timeout="${strelaysrv_messagetimeout}" -network-timeout="${strelaysrv_networktimeout}" -per-session-rate="${strelaysrv_persessionrate}" -ping-interval="${strelaysrv_pinginterval}" -pools="${strelaysrv_pools}" -protocol="${strelaysrv_protocol}" -provided-by="${strelaysrv_providedby}" -status-srv="${strelaysrv_statussrv}"'
exec_start_escaped=$(printf '%s\n' "$exec_start" | sed -e 's/[\/&]/\\&/g')
sed -i -e "/.*ExecStart=/s/^.*$/ExecStart=$exec_start_escaped/" /lib/systemd/system/strelaysrv.service

systemctl daemon-reload
systemctl restart strelaysrv

# hostname-figlet
cat > /etc/update-motd.d/99-1-hostname-figlet <<-EOF
	#!/bin/sh
	hostname | tail -c 8 | figlet
EOF
chmod 755 /etc/update-motd.d/99-1-hostname-figlet

# strelaysrv
cat > /etc/update-motd.d/99-2-strelaysrv <<-EOF
	#!/bin/sh
	echo ''
	echo -n 'iptables: '
	iptables -t nat -L | grep -A2 PREROUTING | tail -n1
	echo -n 'strelaysrv: '
	journalctl -xe | grep 'relay://' | tail -n1 | tr ' ' '\n' | grep 'relay://' | cut -d'&' -f1
	echo -n 'connections: '
	echo \$(netstat -anp | grep strelaysrv | grep ESTABLISHED | wc -l)
	echo 'relays: https://relays.syncthing.net/'
EOF
chmod 755 /etc/update-motd.d/99-2-strelaysrv

rm -f /etc/motd

exit 0
