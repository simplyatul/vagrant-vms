#!/bin/bash
# Ref: https://github.com/iovisor/bcc/blob/master/INSTALL.md#ubuntu---binary

apt-get update
apt-get install bpfcc-tools linux-headers-$(uname -r)

