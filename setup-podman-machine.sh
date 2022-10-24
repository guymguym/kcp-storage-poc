source "$(dirname $0)/env.sh"

podman machine rm
podman machine init --cpus 8 --memory 8192
podman machine start

# using rootless for now, but maybe we'll need rootful later:
#podman machine set --rootful

podman machine ssh --username root bash -c 'cat << EOF > /etc/systemd/system/user@.service.d/delegate.conf
[Service]
Delegate=yes
EOF'
podman machine ssh --username root bash -c 'cat << EOF > /etc/modules-load.d/iptables.conf
ip6_tables
ip6table_nat
ip_tables
iptable_nat
EOF'
podman machine ssh --username root systemctl daemon-reload
podman machine ssh --username root modprobe -v ip6_tables
podman machine ssh --username root lsmod | grep ip6
