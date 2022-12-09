# updateConfig
Update or append multiple lines to a flat config file


## Usage
Either source it or copy oneline version into your script

```bash
updateConfig "/etc/sshd/sshd_config" <<- EOF
  Port 27
  PermitRootLogin prohibit-password
  PasswordAuthentication no
  KbdInteractiveAuthentication no
  PrintMotd no
  UsePAM no
  PermitUserRC no
  LoginGraceTime 10s
  ClientAliveInterval 60
  ClientAliveCountMax 2
EOF
```

Log output example:
```log
[/etc/sshd/sshd_config].update: (#Port 22) => (Port 27)
[/etc/sshd/sshd_config].update: (#LoginGraceTime 2m) => (LoginGraceTime 10s)
[/etc/sshd/sshd_config].update: (#PermitRootLogin no) => (PermitRootLogin prohibit-password)
[/etc/sshd/sshd_config].update: (#PasswordAuthentication no) => (PasswordAuthentication no)
[/etc/sshd/sshd_config].update: (#KbdInteractiveAuthentication yes) => (KbdInteractiveAuthentication no)
[/etc/sshd/sshd_config].update: (#UsePAM yes) => (UsePAM no)
[/etc/sshd/sshd_config].update: (#PrintMotd yes) => (PrintMotd no)
[/etc/sshd/sshd_config].update: (#ClientAliveInterval 0) => (ClientAliveInterval 60)
[/etc/sshd/sshd_config].update: (#ClientAliveCountMax 3) => (ClientAliveCountMax 2)
[/etc/sshd/sshd_config].append: PermitUserRC no
```

You can find more examples in `updateConfig.test.sh` file.

## Files
- updateConfig.sh - main function
- updateConfig.compiled.sh - oneline version
- updateConfig.awk - AWK progfile
- updateConfig.build.sh - script that builds oneline version
- updateConfig.test.sh - test cases
- updateConfig.test.lib.sh - test support functions