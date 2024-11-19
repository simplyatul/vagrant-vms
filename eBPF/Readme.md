# Steps to create and setup a VM for running eBPF programs

Start/Up the VM
```bash
$ vagrant up
```

ssh into vm
```bash
$ vagrant ssh
```
Check the current linux kernel version. It should be as following
```bash
$ uname -r
5.15.0-122-generic
```

Run upgrade script
```bash
$ sudo /shared-with-host/upgrade.sh
```

Post upgrade, come out of ssh, halt the VM and start it again
```bash
$ vagrant halt
$ vagrant up
```
Now check the linux kernel version. It should be upgraded
```bash
$ uname -r
5.15.0-126-generic
```
Now run the remaining scripts
```bash
$ sudo /shared-with-host/bcc-install.sh
$ sudo /shared-with-host/ebpf-install.sh
$ sudo /shared-with-host/generic-tools-install.sh
```
