# LoadBalancer IP Address Management (LB IPAM)
LB IPAM is a feature that allows Cilium to assign IP addresses to Services of type ```LoadBalancer```.  
L2 Announcements / L2 Aware LB (Beta) used to advertise them locally.

Ref:  
https://docs.cilium.io/en/latest/network/lb-ipam/#lb-ipam
https://docs.cilium.io/en/latest/network/l2-announcements/

## Steps to create setup

Create kind cluster
```bash
kind create cluster --config=kind-config.yaml --name cc0
```
Install cilium
```bash
bash install-cmd
```

Wait for complete installation
```bash
cilium status --wait
```

Apply L2 policy and create IP Pool
```bash
k apply -f l2-announcement.yaml 
ciliuml2announcementpolicy.cilium.io/l2-announcement created

k apply -f ippool.yaml 
ciliumloadbalancerippool.cilium.io/blue-pool created
```

Status of l2 resources

```bash
k get ciliuml2announcementpolicies.cilium.io
NAME                AGE
l2-announcement     51s

k get ippools
NAME        DISABLED   CONFLICTING   IPS AVAILABLE   AGE
blue-pool   false      False         100             63s
```

Install echo service w/ type as LoadBalancer
```bash
k apply -f echo-1.yaml
```

Service status looks like

```bash
kubectl get services
NAME         TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
echo-1       LoadBalancer   10.96.79.72   20.0.20.100   8080:30286/TCP   14s
kubernetes   ClusterIP      10.96.0.1     <none>        443/TCP          5m34s
```

Port forward echo service and check
```bash
k port-forward svc/echo-1 8080:8080 &
[1] 38620

Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
```

Call echo service
```bash
curl -s http://localhost:8080/

Handling connection for 8080
Hostname: echo-1-6555b459d9-cb2c2

Pod Information:
        node name:      cc0-worker
        pod name:       echo-1-6555b459d9-cb2c2
        pod namespace:  default
        pod IP: 10.0.0.136

Server values:
        server_version=nginx: 1.12.2 - lua: 10010

Request Information:
        client_address=127.0.0.1
        method=GET
        real path=/
        query=
        request_version=1.1
        request_scheme=http
        request_uri=http://localhost:8080/

Request Headers:
        accept=*/*  
        host=localhost:8080  
        user-agent=curl/7.81.0  

Request Body:
        -no body in request-
```



We can call service using External-IP from any of the k8s node
```bash
docker exec cc0-control-plane curl http://20.0.20.100:8080/
docker exec cc0-worker curl http://20.0.20.100:8080/
```



## Access echo service using LB IP

```bash
docker exec cc0-control-plane curl http://20.0.20.100:8080/
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   497    0   497    0     0   158k      0 --:--:-- --:--:-- --:--:--  242k 

Hostname: echo-1-6555b459d9-cb2c2

Pod Information:
        node name:      cc0-worker
        pod name:       echo-1-6555b459d9-cb2c2
        pod namespace:  default
        pod IP: 10.0.0.136

Server values:
        server_version=nginx: 1.12.2 - lua: 10010

Request Information:
        client_address=10.0.1.97
        method=GET
        real path=/
        query=
        request_version=1.1
        request_scheme=http
        request_uri=http://20.0.20.100:8080/

Request Headers:
        accept=*/*
        host=20.0.20.100:8080
        user-agent=curl/7.88.1

Request Body:
        -no body in request-
```

Note client_address (10.0.1.97) is cilium_hosts interface IP from cc0-control-plane node

```bash
docker exec -it cc0-control-plane ip addr show cilium_host
3: cilium_host@cilium_net: <BROADCAST,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 06:da:d2:e0:05:d9 brd ff:ff:ff:ff:ff:ff
    inet 10.0.1.97/32 scope global cilium_host
       valid_lft forever preferred_lft forever
    inet6 fe80::4da:d2ff:fee0:5d9/64 scope link 
       valid_lft forever preferred_lft forever
```

And access using worker node

```bash
docker exec cc0-worker curl http://20.0.20.100:8080/
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   498    0   498    0     0   191k      0 --:--:-- --:--:-- --:--:--  243k

Hostname: echo-1-6555b459d9-cb2c2

Pod Information:
        node name:      cc0-worker
        pod name:       echo-1-6555b459d9-cb2c2
        pod namespace:  default
        pod IP: 10.0.0.136

Server values:
        server_version=nginx: 1.12.2 - lua: 10010

Request Information:
        client_address=10.0.0.114
        method=GET
        real path=/
        query=
        request_version=1.1
        request_scheme=http
        request_uri=http://20.0.20.100:8080/

Request Headers:
        accept=*/*
        host=20.0.20.100:8080
        user-agent=curl/7.88.1

Request Body:
        -no body in request-
```

Here too, client_address (10.0.0.114) is worker node's cilium_host interface IP address

```bash
docker exec -it cc0-worker ip addr show cilium_host
3: cilium_host@cilium_net: <BROADCAST,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 5e:b5:0f:03:ec:b6 brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.114/32 scope global cilium_host
       valid_lft forever preferred_lft forever
    inet6 fe80::5cb5:fff:fe03:ecb6/64 scope link 
       valid_lft forever preferred_lft forever
```