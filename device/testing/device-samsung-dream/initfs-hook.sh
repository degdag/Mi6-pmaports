#!/bin/sh

# This is a trimmed down version of setup_usb_network_configfs from
# pmOS's init_functions.sh

# See: https://www.kernel.org/doc/Documentation/usb/gadget_configfs.txt
CONFIGFS=/config/usb_gadget

# Create an usb gadet configuration
mkdir $CONFIGFS/g1 || echo "initfs-hook: Couldn't create $CONFIGFS/g1"

# Create rndis function.
mkdir $CONFIGFS/g1/functions/rndis.usb0 \
	|| echo "initfs-hook: Couldn't create $CONFIGFS/g1/functions/rndis.usb0"

# Create configuration instance for the gadget
mkdir $CONFIGFS/g1/configs/c.1 \
	|| echo "initfs-hook: Couldn't create $CONFIGFS/g1/configs/c.1"

# Link the rndis instance to the configuration
ln -s $CONFIGFS/g1/functions/rndis.usb0 $CONFIGFS/g1/configs/c.1 \
	|| echo "initfs-hook: Couldn't symlink rndis.usb0"
