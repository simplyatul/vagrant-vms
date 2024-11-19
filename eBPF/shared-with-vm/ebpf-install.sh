#!/bin/bash
# Ref: https://github.com/lizrice/learning-ebpf/blob/main/learning-ebpf.yaml

apt-get update
apt-get install -y apt-transport-https ca-certificates curl clang llvm jq
apt-get install -y libelf-dev libpcap-dev libbfd-dev binutils-dev build-essential make 
apt-get install -y libbpf-dev
apt-get install -y linux-tools-common linux-tools-$(uname -r)

