#!/bin/sh

# Make sure to read:
# https://wiki.archlinux.org/index.php/QEMU
#
# Download SPICE windows drivers:
# http://www.spice-space.org/download.html
#
# Download virtio windows driver (before install):
# https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso

## SETUP ENVIRONMENT ########################################################
# disable HiDPI settings (SPICE won’t scale properly otherwise)
export GDK_SCALE=1
export GDK_DPI_SCALE=1

# virtual GPU (intel GVT)
export MESA_LOADER_DRIVER_OVERRIDE=i965
GVT_PCI="/sys/bus/pci/devices/0000:00:02.0"
GVT_TYPE="i915-GVTg_V5_4"
GVT_GUID="b1306297-6c1e-404f-81e8-b43aab0aa3b0"

## SETUP VIRTUAL MACHINE ####################################################
# basic QEMU command
COMMAND="qemu-system-x86_64 -display spice-app,gl=on"
# CPU/KVM
COMMAND+="    -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time"
COMMAND+="    -enable-kvm -machine q35 -device intel-iommu,caching-mode=on"
COMMAND+="    -smp 4,cores=2,threads=2"
# memory
COMMAND+="    -m $(echo "$(awk '/MemTotal/{print $2}' /proc/meminfo)/2000" | bc)M"
# USB/Network
COMMAND+="    -usb -device usb-tablet -soundhw hda"
COMMAND+="    -nic user,model=virtio-net-pci,smb=$HOME/var/shared"
# GPU
COMMAND+="    -vga none"
COMMAND+="    -device vfio-pci,sysfsdev=/sys/bus/mdev/devices/$GVT_GUID,"
COMMAND+="display=on,x-igd-opregion=on,ramfb=on,driver=vfio-pci-nohotplug"
# SPICE
COMMAND+="    -device virtio-serial-pci"
COMMAND+="    -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0"
COMMAND+="    -chardev spicevmc,id=spicechannel0,name=vdagent"
COMMAND+="    -spice unix,addr=/tmp/vm_spice.socket,disable-ticketing"
# DISKS
COMMAND+="    -drive file=hdd.qcow2,index=0,media=disk,format=qcow2,if=virtio"

# create HD if not present
if [[ ! -f hdd.qcow2 ]]; then
    if [[ -f hdd0.qcow2 ]]; then
        # create disk from overlay
        qemu-img create -o backing_file=hdd0.qcow2,backing_fmt=qcow2 -f qcow2 hdd.qcow2
    else
        # create empty disk and prepare installation
        COMMAND+=" -drive file=win10.iso,index=2,media=cdrom"
        COMMAND+=" -drive file=virtio.iso,index=3,media=cdrom"
        COMMAND+=" -boot order=d"
    fi
fi

## EXECUTE VM ###############################################################

function sudowrite() { echo "$1" | sudo tee "$2" >/dev/null; }
sudowrite "${GVT_GUID}" "${GVT_PCI}/mdev_supported_types/${GVT_TYPE}/create"

if [[ -d "${GVT_PCI}/${GVT_GUID}/iommu_group" ]]; then
    DEVICE="/dev/vfio/$(realpath ${GVT_PCI}/${GVT_GUID}/iommu_group | sed 's/.*\///')"
    echo -n "Waiting for GPU..." && sleep 5 && echo " OK"
    sudo setfacl -m u:cagprado:rw $DEVICE
    $COMMAND $@
    sudowrite 1 "${GVT_PCI}/${GVT_GUID}/remove"
fi
