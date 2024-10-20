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

