# Virtual Loopback IPs Guide

The simulator runs two “gates” on the same machine by binding each client to its own loopback IP.

## Windows (PowerShell, run as Administrator)
```powershell
# Add
netsh interface ipv4 add address name="Loopback Pseudo-Interface 1" address=127.0.0.2 mask=255.0.0.0
netsh interface ipv4 add address name="Loopback Pseudo-Interface 1" address=127.0.0.3 mask=255.0.0.0

# Verify
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -like '127.*'}

# Remove
netsh interface ipv4 delete address name="Loopback Pseudo-Interface 1" address=127.0.0.2
netsh interface ipv4 delete address name="Loopback Pseudo-Interface 1" address=127.0.0.3
```

## Linux
```bash
sudo ip addr add 127.0.0.2/8 dev lo
sudo ip addr add 127.0.0.3/8 dev lo

# Verify
ip addr show lo

# Remove
sudo ip addr del 127.0.0.2/8 dev lo
sudo ip addr del 127.0.0.3/8 dev lo
```

## macOS
```bash
sudo ifconfig lo0 alias 127.0.0.2 up
sudo ifconfig lo0 alias 127.0.0.3 up

# Verify
ifconfig lo0 | grep 127.

# Remove
sudo ifconfig lo0 -alias 127.0.0.2
sudo ifconfig lo0 -alias 127.0.0.3
```

After adding the aliases, the two gate clients can bind to `127.0.0.2` and `127.0.0.3` while the backend stays on `127.0.0.1`.
