#!/bin/bash
PID_FILE='/var/run/starter.charon.pid'
LOG_FILE='/var/log/StrongswanIptables.log'

######### FUNCTIONS #########
do_start() {

    ip tunnel add vti0 local 10.10.0.10 remote 10.10.0.20 mode vti key 42
    ip link set vti0 up

    ip addr add 10.1.1.2/32 dev vti0
    ip route add 10.1.1.1/32 dev vti0

    ip route add 10.10.3.0/24 dev vti0
    ip route add 10.10.4.0/24 dev vti0

    iptables -w 3 -t nat -I POSTROUTING 1  --destination 10.10.2.0/24 -j ACCEPT
    iptables -w 3 -t nat -I POSTROUTING 1  --source 10.10.2.0/24 -j ACCEPT

    iptables -w 3 -t nat -A POSTROUTING -s 10.1.1.2/32 -d 10.10.3.0/24 -j SNAT --to-source 10.10.2.2
    iptables -w 3 -t nat -A POSTROUTING -s 10.1.1.2/32 -d 10.10.3.0/24 -j SNAT --to-source 10.10.2.2

}

do_stop() {

    iptables -t nat -D POSTROUTING -s 10.1.1.2/32 -d 10.10.3.0/24 -j SNAT --to-source 10.10.2.2
    iptables -t nat -D POSTROUTING -s 10.1.1.2/32 -d 10.10.3.0/24 -j SNAT --to-source 10.10.2.2

    iptables -t nat -D POSTROUTING --destination 10.10.2.0/24 -j ACCEPT
    iptables -t nat -D POSTROUTING --source 10.10.2.0/24 -j ACCEPT
    
    ip route del 10.10.3.0/24 dev vti0
    ip route del 10.10.4.0/24 dev vti0

    ip route del 10.1.1.1/32 dev vti0
    ip addr del 10.1.1.2/32 dev vti0

    ip link set vti0 down
    ip tunnel del vti0 local 10.10.0.10 remote 10.10.0.20 mode vti key 42
    
}

######### MAIN #########
case "$1" in
    start)
	    echo "Configure Iptables, routes and interfaces"
        do_start
    ;;
    stop)
        echo "Stop Iptables, routes and interfaces" >&3
        do_stop
    ;;
    status) 
	    if grep -q "10.1.1.2" $(ip a); then
            echo "Strongswang Iptables, routes and Interfaces are up"
        else
            echo "Strongswang Iptables, routes and Interfaces are down"
        fi
    ;;
    *)
        echo $"Usage: $0 {start|stop|status}"
        exit 1
esac
