#!/bin/sh

# Make sure to read:
# https://wiki.archlinux.org/index.php/QEMU
#
# Download SPICE windows drivers:
# http://www.spice-space.org/download.html
#
# Download virtio windows driver (before install):
# https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso

# make sure HiDPI settings won't mess with guest system
export GDK_SCALE=1
export GDK_DPI_SCALE=1

# prepare virtual GPU (intel GVT)
export MESA_LOADER_DRIVER_OVERRIDE=i965
GVT_PCI="/sys/bus/pci/devices/0000:00:02.0"
GVT_TYPE="i915-GVTg_V5_4"
GVT_GUID="b1306297-6c1e-404f-81e8-b43aab0aa3b0"

echo "${GVT_GUID}" | sudo tee ${GVT_PCI}/mdev_supported_types/${GVT_TYPE}/create > /dev/null
sudo setfacl -m u:cagprado:rw /dev/vfio/18 \
    && sleep 5 || exit 1


if [[ "$HOSTNAME" = "mredson" ]]; then
    export OPTIONS="-smp 4,cores=2,threads=2 -m 8G"
else
    export OPTIONS="-smp 4,cores=2,threads=2 -m 4G"
fi

# load VM
if [[ -f hdd.qcow2 ]]; then
    qemu-system-x86_64 -display spice-app,gl=on \
        -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
        -enable-kvm -machine q35 -device intel-iommu,caching-mode=on $OPTIONS \
        -usb -device usb-tablet -soundhw hda \
        -nic user,model=virtio-net-pci,smb=$HOME/var/shared \
        -vga none \
        -device vfio-pci,sysfsdev=/sys/bus/mdev/devices/$GVT_GUID,display=on,x-igd-opregion=on,ramfb=on,driver=vfio-pci-nohotplug \
        -device virtio-serial-pci \
        -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
        -chardev spicevmc,id=spicechannel0,name=vdagent \
        -spice unix,addr=/tmp/vm_spice.socket,disable-ticketing \
        -drive file=hdd.qcow2,index=0,media=disk,format=qcow2,if=virtio $@

# create overlay image
elif [[ -f hdd0.qcow2 ]]; then
    qemu-img create -o backing_file=hdd0.qcow2,backing_fmt=qcow2 -f qcow2 hdd.qcow2

# install VM
else
    # create drive
    qemu-img create -f qcow2 hdd.qcow2 80G

    # load boot disk to install windows
    qemu-system-x86_64 -display spice-app -boot order=d \
        -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
        -enable-kvm -machine q35 -device intel-iommu $OPTIONS \
        -usb -device usb-tablet -soundhw hda \
        -nic user,model=virtio-net-pci,smb=$HOME/var/shared \
        -vga none -device qxl-vga,vram_size=67108864,vgamem_mb=64 \
        -device virtio-serial-pci \
        -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
        -chardev spicevmc,id=spicechannel0,name=vdagent \
        -spice unix,addr=/tmp/vm_spice.socket,disable-ticketing \
        -drive file=hdd.qcow2,index=0,media=disk,format=qcow2,if=virtio \
        -drive file=win10.iso,index=2,media=cdrom \
        -drive file=virtio.iso,index=3,media=cdrom
fi

# remove GVT device
echo 1 | sudo tee ${GVT_PCI}/${GVT_GUID}/remove > /dev/null
