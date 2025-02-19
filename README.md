# Forcibly unmap BOOTFB memory

### ⚠️  UPDATE 07/2022 ⚠️

From [this](https://forum.proxmox.com/threads/problem-with-gpu-passthrough.55918/post-478351) post on the Proxmox Forum, and by my own testing on the standard Linux kernel `5.18.3`, it is possible to avoid the mapping of the BOOTFB memory region by adding the following argument to the boot command line:
```
initcall_blacklist=sysfb_init
```

Therefore, you have no need to compile and use the kernel module in this repo!

---

This repo will let you compile a kernel module to unmap the memory reserved by the `simple-framebuffer` device.

To ensure that `simplefb` wil not access that memory afterwards, add the following parameter to your command line inside your bootloader:
```
video=simplefb:off
```

This is useful if trying to pass through to a VM the nly machine's primary GPU, which would have a physical or dummy monitor attached to it. In this case, you may get errors in the `dmesg` kernel logs similar to the following, and also the GPU driver in the guest OS will crash:
```
BAR 1: can't reserve [mem 0x00000000-0xefffffff 64bit pref]
```

To check the memory mapping layout, you can look inside the file `/proc/iomem`; if you see a line which has `BOOTFB` beside the memory region interval, it means your system has that portion of memory reserved by the `simplefb` device.

## Update GRUB on EFI (CentOS/Fedora)

1. Edit the file `/etc/default/grub`, adding the parameter to the line `GRUB_CMDLINE_LINUX=`

2. Update the configuration for the EFI entries, with the following command:
```bash
grub2-mkconfig -o /etc/grub2-efi.cfg
```

3. Reboot the system

# Build

## Dependencies (CentOS/Fedora)

```bash
sudo dnf install -y kernel-devel kernel-headers dkms
```

## Compile (CentOS/Fedora)

1. Be sure that a symlink to `/usr/src/kernel` exists inside `/lib/modules/$(uname -r)`, run the following command otherwise:
```bash
sudo ln -s /usr/src/kernels/$(uname -r)/ /lib/modules/$(uname -r)/build
```

2. Compile the kernel module inside this folder

```bash
sudo make
```

3. Install the module to be able to use it with `modprobe`

```bash
sudo make install
```

## Automatic recompile with DKMS

Run the following commands from this repository's root folder:

```bash
sudo dkms add $(pwd)
sudo dkms build -m force-remove-bootfb -v 0.0.1
sudo dkms install -m force-remove-bootfb -v 0.0.1
```

Check that the module is correctly installed by running the following:

```bash
dkms status | grep force-remove-bootfb
```

If you see an output similar to this, then DKMS will take care of recompiling that module for the next different kernel you will install on your system

```
force-remove-bootfb/0.0.1, ... x86_64: installed (original_module exists)
```

# Run

## Manually

Run as root from the bash script with the following command:

- To use the locally built module from the `build` folder, run
```bash
sudo ./remove.sh
```

- To use the DKMS built kernel module, run
```bash
sudo ./remove-with-dkms.sh
```

- To unbind any framebuffer device that might be active, run
```bash
sudo ./remove-all-fb.sh
```

**NOTE**: After every reboot, the script `remove.sh` should be run again to unmap the memory region reserved by `simplefb`.

## Automatically (SystemD and DKMS)

Install the `.service` unit file and the soft link with the following commands:
```bash
ln -s $(pwd)/remove-with-dkms.sh /usr/local/bin/bootfb-unmap.sh
cp bootfb-unmap.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable bootfb-unmap.service
```

At each reboot, the script which uses the DKMS module will run automatically.

# Source

by Robert Ou ( @rqou ?? )

https://lists.gnu.org/archive/html/qemu-devel/2016-07/msg02469.html
