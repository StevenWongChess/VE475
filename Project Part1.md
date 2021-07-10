### VE489 Project Report for Part 1:

The demo video link is here https://jbox.sjtu.edu.cn/v/link/view/a6ca1e50cd7542a194f0375a58f81c74

Team members: Wang Yichao, Lao Danning

Linux is required.  I am using MacOS 10.15.7 and run Ubuntu 20.04.2 on virtual machine as my host. Important bash commands are commented for easier understanding. 

### Step A: Install docker using package manager.

Reference: https://docs.docker.com/engine/install/ubuntu/

```bash
# remove old version dock(if have)
sudo apt-get remove docker docker-engine docker.io containerd runc
# update package manager
sudo apt-get update 
#install required packages
sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release 
# add doccker official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# set up stable repo (Pls change (lsb_release -cs) into focal)
# echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu (lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu focal stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# install docker engine(specific version can be chosen as well)
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
# verify the success of installation
sudo docker version or docker -v
sudo docker run hello-world
# to run docker on booting
sudo systemctl enable docker
# Note: The docker group is created but no users are added to it. You need to use sudo to run Docker commands. To get rid of sudo, see https://docs.docker.com/engine/install/linux-postinstall/ 
```

```bash
# Trouble shooting
Err:6 https://download.docker.com/linux/ubuntu (lsb_release Release
  404  Not Found [IP: 10.16.151.136 443]
Solution: reinstall the Linux virtual machine ~~o(>_<)o~~
```

```bash
# To unistall
sudo apt-get purge docker-ce docker-ce-cli containerd.io
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
# You must delete any edited configuration files manually.
```

### Step B: start docker with ```systemctl```

```bash
# to pull image (first docker search)
sudo docker pull ubuntu:18.04
# rename image(just an alias)
sudo docker image tag ubuntu:18.04 rookie:18.04
# show the list of images
sudo docker image ls 
# to inspect, run
sudo docker image inspect 7d0d8fa37224

# to build a container and name it as first_container
sudo docker run --name first_container -t -i rookie:18.04
# to start the container
sudo docker start -i first_container
# this is similar to screen share with remote control right
sudo docker attach first_container
# to exit
exit
```

### Step C: Start bash and play

```bash
# run bash on container
sudo docker run --name bash_test -t -i rookie:18.04 /bin/bash
sudo docker ps -a
```

### Step D: Install flannel

```bash
### reference: https://www.programmersought.com/article/38231930467/
# find ip address for host
sudo apt-get install net-tools
ifconfig # look for ens33 and get inet = 127.0.0.1 inet 172.16.143.129

######### install etcd
# https://github.com/etcd-io/etcd/releases/tag/v3.3.10
# trouble shooting etcdv3 is not supported by flannel, so we need to use prior version of etcd instead, for detail, see https://github.com/flannel-io/flannel/issues/1191
touch etcd.sh
chmod +x etcd.sh
./etcd.sh

touch /usr/lib/systemd/system/etcd.service
sudo gedit /usr/lib/systemd/system/etcd.service
# sudo systemctl unmask etcd
sudo systemctl enable etcd
sudo systemctl start etcd

/* not useful yet
# start a local etcd server
/tmp/etcd-download-test/etcd
# write,read to etcd
/tmp/etcd-download-test/etcdctl --endpoints=localhost:2379 put foo bar
/tmp/etcd-download-test/etcdctl --endpoints=localhost:2379 get foo
*/

########## install flannel on host machine
wget https://github.com/flannel-io/flannel/releases/download/v0.14.0/flannel-v0.14.0-linux-amd64.tar.gz
tar -zxvf flannel-v0.14.0-linux-amd64.tar.gz
sudo cp flanneld /usr/bin
flanneld --version
touch flannel-config.json
gedit flannel-config.json
etcdctl set /docker-flannel/network/config < flannel-config.json
# trouble shooting, use "put" instead of "set"
# pls see https://github.com/etcd-io/etcd/issues/9600 
sudo touch /usr/lib/systemd/system/flanneld.service
# !!for virtual machine the tag in config file should be --iface=ens33s
sudo gedit /usr/lib/systemd/system/flanneld.service
sudo systemctl enable flanneld
sudo systemctl start flanneld
# to check 
sudo systemctl status flanneld
ip r 
```

```bash
# /**** contents of etcd.sh ****/
ETCD_VER=v3.3.10

# choose either URL
GOOGLE_URL=https://storage.googleapis.com/etcd
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${GOOGLE_URL}

rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
rm -rf /tmp/etcd-download-test && mkdir -p /tmp/etcd-download-test

curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd-download-test --strip-components=1
rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz

sudo mv /tmp/etcd-download-test/etcd /usr/bin
sudo mv /tmp/etcd-download-test/etcdctl /usr/bin
```

```bash
# /**** Contents of /usr/lib/systemd/system/etcd.service ****/
[Unit]
Description=etcd
After=network.target
[Service]
Environment=ETCD_NAME=etcd-1
Environment=ETCD_DATA_DIR=/var/lib/etcd
Environment=ETCD_LISTEN_CLIENT_URLS=http://172.16.143.129:2379,http://127.0.0.1:2379
Environment=ETCD_LISTEN_PEER_URLS=http://172.16.143.129:2380
Environment=ETCD_ADVERTISE_CLIENT_URLS=http://172.16.143.129:2379,http://127.0.0.1:2379
Environment=ETCD_INITIAL_ADVERTISE_PEER_URLS=http://172.16.143.129:2380
Environment=ETCD_INITIAL_CLUSTER_STATE=new
Environment=ETCD_INITIAL_CLUSTER_TOKEN=etcd-cluster-token
Environment=ETCD_INITIAL_CLUSTER=etcd-1=http://172.16.143.129:2380
ExecStart=/usr/bin/etcd
[Install]
WantedBy=multi-user.target
```

```bash
# /**** Contents of flannel-config.json ****/
# see example in https://github.com/flannel-io/flannel/blob/master/Documentation/configuration.md
{
  "Network": "10.3.0.0/16",
  "SubnetLen": 24,
  "Backend": {
    "Type": "vxlan"
  }
}
```

```bash
# /**** Contents of /usr/lib/systemd/system/flanneld.service ****/
[Unit]
Description=flannel
After=etcd.service network.target

[Service]
ExecStart=/usr/bin/flanneld --etcd-endpoints=http://172.16.143.129:2379 -etcd-prefix=/docker-flannel/network  --iface=ens33

[Install]
WantedBy=multi-user.target
```

### Step E: Set IP address

```bash
# edit docker config
sudo gedit /run/flannel/subnet.env
sudo gedit /usr/lib/systemd/system/docker.service
# add --bip=10.3.90.1/24 --mtu=1450 accordingly

# restart docker
sudo systemctl daemon-reload
sudo systemctl restart docker

# for testing
apt-get install iputils-ping
ping google.com
```

### Step F: Install SSH

```bash
apt-get update
apt-get install ssh
apt-get install net-tools
service ssh start
# in the first container 
useradd bukeepdehanhan
passwd bukeepdehanhan

ssh bukeepdehanhan@${ip} 
# that's all;
```



![](/Users/stevenwong/Downloads/success.png)



```bash
# original /usr/lib/systemd/system/docker.service
# I make a backup here /usr/lib/systemd/system/docker_backup.service
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service containerd.service
Wants=network-online.target
Requires=docker.socket containerd.service

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

# Note that StartLimit* options were moved from "Service" to "Unit" in systemd 229.
# Both the old, and new location are accepted by systemd 229 and up, so using the old location
# to make them work for either version of systemd.
StartLimitBurst=3

# Note that StartLimitInterval was renamed to StartLimitIntervalSec in systemd 230.
# Both the old, and new name are accepted by systemd 230 and up, so using the old name to make
# this option work for either version of systemd.
StartLimitInterval=60s

# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity

# Comment TasksMax if your systemd version does not support it.
# Only systemd 226 and above support this option.
TasksMax=infinity

# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes

# kill only the docker process, not all processes in the cgroup
KillMode=process
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target
```

```bash
link that might help
https://hub.packtpub.com/coreos-networking-and-flannel-internals/
https://blog.laputa.io/kubernetes-flannel-networking-6a1cb1f8ec7c
https://www.cnblogs.com/YaoDD/p/7681811.html
https://daimajiaoliu.com/daima/4ee017ca11003e4
https://stackoverflow.com/questions/34439659/flannel-and-docker-dont-start
https://github.com/flannel-io/flannel/blob/master/Documentation/configuration.md
https://docker-k8s-lab.readthedocs.io/en/latest/docker/docker-flannel.html
https://docs.docker.com/config/containers/container-networking/
https://www.slideshare.net/lorispack/using-coreos-flannel-for-docker-networking
https://www.programmersought.com/article/38231930467/
https://www.runoob.com/docker/docker-container-usage.html
```







