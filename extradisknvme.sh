#bash
setupdisk(){
	lsblk
	read -p "what disk: " diskan
	fdisk /dev/$diskan <<EEOF
	g
	n



	w
EEOF
	cryptsetup luksFormat /dev/${diskan}p1
	read -p "what do you want your disk to be called: " sdname
	cryptsetup open --type luks /dev/${diskan}p1 $sdname
	mkfs.ext4 /dev/mapper/$sdname
	dd if=/dev/urandom of=/root/keyfile bs=1024 count=4
	chmod 0400 /root/keyfile
	cryptsetup luksAddKey /dev/${diskan}p1 /root/keyfile
	echo "$sdname /dev/${diskan}p1 /root/keyfile luks" | tee -a /etc/crypttab
	mkdir /mnt/$sdname;
	echo "/dev/mapper/$sdname /mnt/$sdname ext4 defaults 0 2" | tee -a /etc/fstab
}
setupdisk

#Setup another disk
	read -p "do you want to setup another disk (y/N) " an
			case $an in
				[yY] ) echo ok;
					read -p "NVME or SATA" ns
						case $ns in
							SATA )
								./extradisk.sh;
								break;;
							NVME )
								setupdisk;
								break;;
						esac;
					break;;
				* ) echo ok;
					break;;
			esac
