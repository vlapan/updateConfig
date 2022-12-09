#!/usr/bin/env bash

set -e

. updateConfig.sh
. updateConfig.test.lib.sh

testcase 'sshd_config like: should append if input doesnt exists' <<- EOF
  --- INPUT ---
  Key1 NO
  --- DATA ---
  --- EXPECTED OUTPUT ---
  Key1 NO
  --- EXPECTED LOG ---
  [/path/to/file.conf].append: Key1 NO
EOF

testcase 'sshd_config like: should update if there is entry with same key' <<- EOF
  --- INPUT ---
  Key1 YES
  --- DATA ---
  Key1 NO
  Key2 NO
  --- EXPECTED OUTPUT ---
  Key1 YES
  Key2 NO
  --- EXPECTED LOG ---
  [/path/to/file.conf].update: (Key1 NO) => (Key1 YES)
EOF

testcase 'sshd_config like: should remove if input is prefixed with "^"' <<- EOF
  --- INPUT ---
  ^Key2
  --- DATA ---
  Key1 NO
  Key2 NO
  --- EXPECTED OUTPUT ---
  Key1 NO
  --- EXPECTED LOG ---
  [/path/to/file.conf].remove: Key2 NO
EOF

testcase 'sshd_config like: should remove entries with duplicate keys after previous update' <<- EOF
  --- INPUT ---
  Key1 YES
  --- DATA ---
  Key1 NO
  Key2 NO
  Key1 NO
  --- EXPECTED OUTPUT ---
  Key1 YES
  Key2 NO
  --- EXPECTED LOG ---
  [/path/to/file.conf].update: (Key1 NO) => (Key1 YES)
  [/path/to/file.conf].remove: Key1 NO
EOF

testcase 'sshd_config like: should merge sequential entries with duplicate keys into one update' <<- EOF
  --- INPUT ---
  Key1 YES
  --- DATA ---
  Key1 NO
  Key1 NO
  --- EXPECTED OUTPUT ---
  Key1 YES
  --- EXPECTED LOG ---
  [/path/to/file.conf].update: (
      Key1 NO
      Key1 NO
  ) => (Key1 YES)
EOF

testcase 'sshd_config like: multiple keys' <<- EOF
  --- INPUT ---
  HostKey /etc/ssh/ssh_host_rsa_key # comment
  HostKey /etc/ssh/ssh_host_ecdsa_key # yeah
  HostKey /etc/ssh/ssh_host_ed25519_key
  --- DATA ---
  #HostKey /etc/ssh/ssh_host_ecdsa_key
  #HostKey /etc/ssh/ssh_host_ed25519_key
  #HostKey2 /etc/ssh/ssh_host_ed25519_key
  --- EXPECTED OUTPUT ---
  HostKey /etc/ssh/ssh_host_rsa_key # comment
  HostKey /etc/ssh/ssh_host_ecdsa_key # yeah
  HostKey /etc/ssh/ssh_host_ed25519_key
  #HostKey2 /etc/ssh/ssh_host_ed25519_key
  --- EXPECTED LOG ---
  [/path/to/file.conf].update: (
      #HostKey /etc/ssh/ssh_host_ecdsa_key
      #HostKey /etc/ssh/ssh_host_ed25519_key
  ) => (
      HostKey /etc/ssh/ssh_host_rsa_key # comment
      HostKey /etc/ssh/ssh_host_ecdsa_key # yeah
      HostKey /etc/ssh/ssh_host_ed25519_key
  )
EOF

testcase 'rc.conf like: should update commented one, uncomment' <<- EOF
  --- INPUT ---
  daemon_enabled="NO"
  --- DATA ---
  # daemon_enabled="NO"
  --- EXPECTED OUTPUT ---
  daemon_enabled="NO"
  --- EXPECTED LOG ---
  [/path/to/file.conf].update: (# daemon_enabled="NO") => (daemon_enabled="NO")
EOF

testcase 'rc.conf like: should update commented one, comment' <<- EOF
  --- INPUT ---
  # daemon_enabled="NO"
  --- DATA ---
  daemon_enabled="NO"
  --- EXPECTED OUTPUT ---
  # daemon_enabled="NO"
  --- EXPECTED LOG ---
  [/path/to/file.conf].update: (daemon_enabled="NO") => (# daemon_enabled="NO")
EOF

testcase 'rc.conf like: complex append/update comment/uncomment' <<- EOF
  --- INPUT ---
  daemon_enabled="YES" # comment
  # monit_enabled="NO"
  hostname="host.example.org"
  sshd_enabled="YES"
  --- DATA ---
  hostname="host.example.com"
  monit_enabled="YES" # comment
  # daemon_enabled="NO"
  daemon_flags="-f"
  daemon_enabled="NO"
  --- EXPECTED OUTPUT ---
  hostname="host.example.org"
  # monit_enabled="NO"
  daemon_enabled="YES" # comment
  daemon_flags="-f"
  sshd_enabled="YES"
  --- EXPECTED LOG ---
  [/path/to/file.conf].update: (hostname="host.example.com") => (hostname="host.example.org")
  [/path/to/file.conf].update: (monit_enabled="YES" # comment) => (# monit_enabled="NO")
  [/path/to/file.conf].update: (# daemon_enabled="NO") => (daemon_enabled="YES" # comment)
  [/path/to/file.conf].remove: daemon_enabled="NO"
  [/path/to/file.conf].append: sshd_enabled="YES"
EOF

testcase 'sysctl.conf like: complex' <<- EOF
  --- INPUT ---
  net.inet.tcp.cc.algorithm=newreno
  ^net.inet.tcp.cc.htcp.adaptive_backoff
  ^net.inet.tcp.cc.htcp.rtt_scaling
  security.mac.portacl.port_high=1023
  security.mac.portacl.suser_exempt=1
  security.mac.portacl.rules=uid:53:tcp:53,uid:53:udp:53,uid:53:tcp:953,uid:53:udp:953
  --- DATA ---
  net.inet.tcp.cc.algorithm=htcp
  net.inet.tcp.cc.htcp.adaptive_backoff=1
  net.inet.tcp.cc.htcp.rtt_scaling=1
  --- EXPECTED OUTPUT ---
  net.inet.tcp.cc.algorithm=newreno
  security.mac.portacl.suser_exempt=1
  security.mac.portacl.port_high=1023
  security.mac.portacl.rules=uid:53:tcp:53,uid:53:udp:53,uid:53:tcp:953,uid:53:udp:953
  --- EXPECTED LOG ---
  [/path/to/file.conf].update: (net.inet.tcp.cc.algorithm=htcp) => (net.inet.tcp.cc.algorithm=newreno)
  [/path/to/file.conf].remove: net.inet.tcp.cc.htcp.adaptive_backoff=1
  [/path/to/file.conf].remove: net.inet.tcp.cc.htcp.rtt_scaling=1
  [/path/to/file.conf].append: security.mac.portacl.suser_exempt=1
  [/path/to/file.conf].append: security.mac.portacl.port_high=1023
  [/path/to/file.conf].append: security.mac.portacl.rules=uid:53:tcp:53,uid:53:udp:53,uid:53:tcp:953,uid:53:udp:953
EOF

testcase 'loader.conf like: complex' <<- EOF
  --- INPUT ---
  cc_htcp_load="YES"
  mac_portacl_load="YES"
  ^machdep.hyperthreading_allowed
  --- DATA ---
  autoboot_delay="-1"
  mac_portacl_load="NO"
  machdep.hyperthreading_allowed="0"
  net.inet.tcp.soreceive_stream="1"
  net.link.ifqmaxlen="2048"
  net.isr.defaultqlimit="4096"
  net.isr.maxthreads="-1"
  net.isr.bindthreads="1"
  --- EXPECTED OUTPUT ---
  autoboot_delay="-1"
  mac_portacl_load="YES"
  net.inet.tcp.soreceive_stream="1"
  net.link.ifqmaxlen="2048"
  net.isr.defaultqlimit="4096"
  net.isr.maxthreads="-1"
  net.isr.bindthreads="1"
  cc_htcp_load="YES"
  --- EXPECTED LOG ---
  [/path/to/file.conf].update: (mac_portacl_load="NO") => (mac_portacl_load="YES")
  [/path/to/file.conf].remove: machdep.hyperthreading_allowed="0"
  [/path/to/file.conf].append: cc_htcp_load="YES"
EOF


testcase 'fstab like: should replace: tabs symbol' <<- EOF
  --- INPUT ---
  fdesc		/dev/fd		FDESCFS	rw	1	1
  --- DATA ---
  # Device	Mountpoint	FStype	Options	Dump	Pass#
  /dev/vtbd0s1a	/		ufs	rw	1	1
  /dev/vtbd0s1b	none		swap	sw	0	0
  fdesc		/dev/fd		fdescfs	rw	0	0
  proc		/proc		procfs	rw	0	0
  --- EXPECTED OUTPUT ---
  # Device	Mountpoint	FStype	Options	Dump	Pass#
  /dev/vtbd0s1a	/		ufs	rw	1	1
  /dev/vtbd0s1b	none		swap	sw	0	0
  fdesc		/dev/fd		FDESCFS	rw	1	1
  proc		/proc		procfs	rw	0	0
  --- EXPECTED LOG ---
  [/path/to/file.conf].update: (
      fdesc		/dev/fd		fdescfs	rw	0	0
  ) => (
      fdesc		/dev/fd		FDESCFS	rw	1	1
  )
EOF

testcase 'fstab like: should replace: tabs char' <<- EOF
  --- INPUT ---
  fdesc\t\t/dev/fd\t\tFDESCFS\trw\t1\t1
  --- DATA ---
  # Device	Mountpoint	FStype	Options	Dump	Pass#
  /dev/vtbd0s1a	/		ufs	rw	1	1
  /dev/vtbd0s1b	none		swap	sw	0	0
  fdesc		/dev/fd		fdescfs	rw	0	0
  proc		/proc		procfs	rw	0	0
  --- EXPECTED OUTPUT ---
  # Device	Mountpoint	FStype	Options	Dump	Pass#
  /dev/vtbd0s1a	/		ufs	rw	1	1
  /dev/vtbd0s1b	none		swap	sw	0	0
  fdesc		/dev/fd		FDESCFS	rw	1	1
  proc		/proc		procfs	rw	0	0
  --- EXPECTED LOG ---
  [/path/to/file.conf].update: (
      fdesc		/dev/fd		fdescfs	rw	0	0
  ) => (
      fdesc		/dev/fd		FDESCFS	rw	1	1
  )
EOF
