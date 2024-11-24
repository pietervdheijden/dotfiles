# Arch notes

## Installation decisions
- File system: ext4
- Partitioning scheme: 
    - `/boot`: 1G
    - `[SWAP]`: 4G
    - `/`: remainder
- Network manager: NetworkManager
- Boot loader: GRUB

## Fix battery drain in suspend mode on Lenovo ThinkPad T14 Gen 5 AMD
To fix the suspend battery drain on Lenovo ThinkPad T14 Gen 5 AMD, add `acpi.ec_no_wakeup=1` to the GRUB kernel command line:

- Open file `/etc/default/grub`.
- Add `acpi_ec_no_wakeup=1` to parameter `GRUB_CMDLINE_LINUX_DEFAULT`. For example: `GRUB_CMDLINE_LINUX_DEFAULT="quiet splash acpi.ec_no_wakeup=1"`.
- Save and close file.
- Update GRUB configuration: `sudo grub-mkconfig -o /boot/grub/grub.cfg`.
- Reboot system for changes to take effect: `sudo reboot`.

Source:  https://bbs.archlinux.org/viewtopic.php?id=298895

Note: the Lenovo ThinkPad T14 Gen 5 AMD does not (yet) support Suspend-to-RAM (S3). 

## Fix Microphone F4 light on Lenovo ThinkPad T14 Gen 5 AMD
If the microphone (F4) light on your Lenovo ThinkPad T14 Gen 5 AMD stays on, you can synchronize it with the actual microphone mute state by creating a script and a systemd service.

First, create a script at `/usr/local/bin/update-mic-led.sh` with the following content:

```
#!/bin/bash

# Set your microphone source
MIC_SOURCE="alsa_input.pci-0000_c4_00.6.HiFi__Mic1__source"

# Check the mute state of the microphone
MIC_STATE=$(pactl get-source-mute "$MIC_SOURCE" | awk '{print $2}')

# Update the LED based on the mute state
if [[ "$MIC_STATE" == "yes" ]]; then
    echo 0 | sudo tee /sys/class/leds/platform::micmute/brightness
else
    echo 1 | sudo tee /sys/class/leds/platform::micmute/brightness
fi
```

And make the script executable:

```
chmod +x /usr/local/bin/update-mic-led.sh
```

Then, create a systemd service file at `/etc/systemd/system/update-mic-led.service` with the following content:

```
[Unit]
Description=Sync microphone state with LED
After=multi-user.target

[Service]
ExecStart=/usr/local/bin/update-mic-led.sh
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
```

Finally, reload the systemd daemon and enable the service:

```
sudo systemctl daemon-reload
sudo systemctl enable --now update-mic-led.service
```

