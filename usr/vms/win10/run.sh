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

## SETUP VIRTUAL MACHINE ####################################################
GPU_MODE=0  # 0 - vxl    1 - GVTi    2 - Passthrough (not implemented)

# basic QEMU command
COMMAND="qemu-system-x86_64 -monitor stdio -display spice-app,gl=on"
# CPU/KVM
COMMAND+="    -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time"
COMMAND+="    -enable-kvm -machine q35 -device intel-iommu,caching-mode=on"
COMMAND+="    -smp 4,cores=2,threads=2"
# memory
COMMAND+="    -m $(echo "$(awk '/MemTotal/{print $2}' /proc/meminfo)/2000" | bc)M"
# USB/Audio/Network
COMMAND+="    -usb -device usb-tablet"
COMMAND+="    -device intel-hda -device hda-duplex"
COMMAND+="    -nic user,model=virtio-net-pci,smb=$HOME/var/shared"
# GPU
if [[ $GPU_MODE -eq 0 ]]; then
    COMMAND+="    -vga none"
    COMMAND+="    -device qxl-vga,vgamem_mb=256,vram_size_mb=256"

elif [[ $GPU_MODE -eq 1 ]]; then
    export MESA_LOADER_DRIVER_OVERRIDE=i965
    GVT_PCI="/sys/bus/pci/devices/0000:00:02.0"
    GVT_TYPE="i915-GVTg_V5_4"
    GVT_GUID="b1306297-6c1e-404f-81e8-b43aab0aa3b0"

    COMMAND+="    -vga none"
    COMMAND+="    -device vfio-pci,sysfsdev=/sys/bus/mdev/devices/$GVT_GUID,"
    COMMAND+="display=on,x-igd-opregion=on,ramfb=on,driver=vfio-pci-nohotplug"

fi
# SPICE
COMMAND+="    -device virtio-serial-pci"
COMMAND+="    -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0"
COMMAND+="    -chardev spicevmc,id=spicechannel0,name=vdagent"
COMMAND+="    -spice unix,addr=/tmp/vm_spice.socket,disable-ticketing"
# DISKS
OVMF="/usr/share/edk2-ovmf/x64/OVMF.fd"
COMMAND+="    -drive if=pflash,read-only,file=$OVMF"
COMMAND+="    -drive if=virtio,media=disk,file=hdd.img,"
COMMAND+="discard=unmap,detect-zeroes=unmap"

# create HD if not present
if [[ ! -f hdd.img ]]; then
    if [[ -f hdd0.img ]]; then
        # create disk from overlay
        qemu-img create -o backing_file=hdd0.img,backing_fmt=qcow2 -f qcow2 hdd.img
    else
        # create empty disk and prepare installation
        qemu-img create -f qcow2 hdd.img 80G
        INSTALL="true"
    fi
fi

# force install regardless if we created HD file or not
if [[ "$1" == "install" ]] && shift || [[ "$INSTALL" == "true" ]]; then
    COMMAND+=" -drive index=1,media=cdrom,file=win10.iso"
    COMMAND+=" -drive index=2,media=cdrom,file=virtio.iso"
    COMMAND+=" -boot once=d"
fi

## EXECUTE VM ###############################################################

if [[ $GPU_MODE -eq 0 ]]; then
    $COMMAND $@

elif [[ $GPU_MODE -eq 1 ]]; then
    function sudowrite() { echo "$1" | sudo tee "$2" >/dev/null; }
    sudowrite "${GVT_GUID}" "${GVT_PCI}/mdev_supported_types/${GVT_TYPE}/create"

    if [[ -d "${GVT_PCI}/${GVT_GUID}/iommu_group" ]]; then
        DEVICE="/dev/vfio/$(realpath ${GVT_PCI}/${GVT_GUID}/iommu_group | sed 's/.*\///')"
        echo -n "Waiting for GPU..." && sleep 5 && echo " OK"
        sudo setfacl -m u:$(whoami):rw $DEVICE
        $COMMAND $@
        sudowrite 1 "${GVT_PCI}/${GVT_GUID}/remove"
    fi
fi
