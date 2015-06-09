# kickstart-ovirt-with-gluster
Automate most of a ovirt-with-gluster-and-hosted-engine setup by using kickstart and just a bunch of scripts

*Intention*
For a datacenter-in-a-box setup at home, I wanted to use a virtualization solution being hosted as a all-in-one on a single machine with no need for any external storage (like a NAS box), capable of nested virtualization.

oVirt hosted engine with gluster seemed to be the right solution, and I found Jason Brooks' blog posts http://community.redhat.com/blog/2014/10/up-and-running-with-ovirt-3-5/ and http://community.redhat.com/blog/2014/11/up-and-running-with-ovirt-3-5-part-two/ achieving exactly this.

To be able to repeat the same setup even after a few month or years when it is time to upgrade my hardware for example, I wanted to pack all those answer files and commands in a single kickstart file for easier use and maintenance.

Since I am using my individual defaults like networks and MAC addresses, this setup is not flexible at all unless you modify the files yourselve, but on the other hand you get an out-of-the-box running oVirt environment without going through all the tries and failures I went through :-)

As in the meantime oVirt 3.5.1 supports also RHEL 7 as the hosted engine OS, I changed that in Jason's setup and also changed the required nodes for the gluster cluster to two instead of 3; that's because I didn't want to run several hypervisors in my celaar 24x7, but only one, which should be extended by another one for migration purposes only, namely when I want to upgrade my server to a new hardware.

<br><b>Defaults/Requirements</b><br><br>
<i>Physical networks:</i><br>
admin/internal network: 172.21.0.0/24 ("ovirtmgmt")<br>
DMZ network: 172.19.0.0/24 ("DMZ")<br>
public network: 192.168.178.0/24 ("Public") via DHCP from DSL router<br>

<i>IPs:</i><br>
virtstorage: 172.21.0.99/24 (controlled by ctdb HA failover)<br>
virtmanager: 172.21.0.100/24<br>
virthost01: 172.21.0.101/24<br>
virthost02: 172.21.0.102/24<br>
virthost03: 172.21.0.103/24<br>

<i>Storage:</i><br>
sda, sdb: 2 identical harddisks (min. 100GB) being set up as:<br>

1. /boot on sda1+sdb1 with software raid (mirrored, RAID 1): 500MB

2. encrypted physical volume pv.1 on sda2+sdb2 with software raid (mirrored, RAID 1): remaining disk space

Filesystems:
/ (20GB) on XFS filesystem
/var/log (2GB) on XFS filesystem
/gluster (50GB) on XFS filesystem
Swap (16GB)



<br><b>Installation workflow</b><br><br>
This section describes the steps needed to set up the complete setup of hypervisor and virtualization management engine:

1. Prepare USB stick by downloading CentOS 7 ISO image (http://mirrors.kernel.org/centos/7.1.1503/isos/x86_64/CentOS-7-x86_64-Minimal-1503-01.iso (636MB) or http://mirrors.kernel.org/centos/7.1.1503/isos/x86_64/CentOS-7-x86_64-Everything-1503-01.iso (7GB)) and write it to the USB stick using dd (or any other tool as described in http://wiki.centos.org/HowTos/InstallFromUSBkey)

2. Prepare your kickstart file with the gen-ks-from-template.sh and modify where needed (e.g. network devices, one instead of default two harddisks etc.); then upload it to any place that can be reached from your new server via HTTP, NFS or similar.

3. Boot your server from the USB key (you may need to press F11 or F12 during BIOS startup to bring up the boot device menu) and choose "Installation" with the arrow keys and then press <TAB>; add "ks=<URL-to-your-upload-kickstart-file" to the boot command line to point the installer to your kickstart file and press <Enter>. This will take quite some time (up to half an hour) because the installed system will be updated right after installation and the USB stick will be copied to the harddisk.

4. After installation has finished and server has rebooted, you are prompted for the harddisk encryption password (1234567890); after that, login with "root" and run "/root/step_1_on_virthost01_hosted-engine-deploy.sh" (use <TAB> for automatic name completion); confirm the follwing questions unless you want to use different installation media vor the hosted engine. Note that you can safely ignore possible errors in regards to multipath.

5. When asked by the setup tool to enter 1,2,3 or 4, use any computer connected to the 172.21.0.0/24 network (e.g. assign a static IP of 172.21.0.5 with netmask 255.255.255.0 to it) that has a VNC viewer installed (e.g. "remote-viewer" from the virt-viewer RPM package, installed with "yum install virt-viewer") to connect to the newly created hosted engine virtual machine: "remote-viewer vnc://172.21.0.101:5900". For the password, use the one mentioned by the setup tool ("...Use the temporary password "..." to connect to the vnc console.")

6. When successfully connected to the graphical boot screen of the hosted engine, you can either use the provided kickstart file by adding "ksdevice=eth0 ip=172.21.0.100 netmask=255.255.255.0 ks=nfs:172.21.0.101:/meta/virtmanager-ks.cfg" to the boot kernel command line after having executed /root/iptables-open-nfs-ports.sh on virthost01 or use the manual installation method by waiting for the installation program to start; press "Continue" to proceed with english as the installation language. You will be presented with an installation setup overview now; change the items in the following order:

* Keyboard layout: add the layout of your choice (e.g. "German (eliminate dead keys)" with the "+" button and remove the default "English (US)" by selecting it and pressing the "-" button. Confirm with "Done" in the upper left corner.
* Choose "Installation Destination" and confirm automatic partitiong with "Done" in the upper left corner.
* Choose "Network & Hostname" and replace "localhost.localdomain" with "virtmanager.[yourdomain]" in the lower left area; then press the "Configure" button in the lower right area. Now choose the "IPv4 Settings" tab and change "Automatic (DHCP)" to "Manual"; press the "Add" button and enter "172.21.0.100" for the address, "255.255.255.0" for the Netmask and switch to the "General" tab. Check the "Automatically connect to this network when it is available" box and confirm all settings with "Save". Leave the network dialog with "Done" in the upper left corner.
* Choose "Date & Time" and select your time zone (e.g. "Berlin") and confirm with "Done" in the upper left corner.
Now that everything is set up, continue with "Begin installation" in the lower right corner. In the next dialog, choose "Root password" and confirm with "Done" in the upper left corner after entering a password twice.
As soon as the installation has finished and the installation tool asks to press the "reboot" button, first head back to your terminal on the virthost01 machine and select 1 before pressing the "Reboot" button.

7. Wait for the setup tool to start the hosted engine virtual machine again and run "/root/step_1.1_on_virthost01_hosted-engine-configure.sh" in a second terminal window (switch to a new one with <Alt-F2> and login with "root" again; switch between terminals with <Alt-F1> and <Alt-F2>).
You will be prompted several times for defining a password and then entering a username and this password again; for your convenience, simply enter "ovirt" every time.
Being asked to confirm to continue connecting, enter "yes" and press <enter>; then enter the password for the root user you defined earlier during the virtual machine installation (you will be asked twice).
Now wait for the setup script to complete the configuration of the hosted engine virtual machine, which can take a long time (half an hour) because updates and additional packages will be installed from the internet.

8. When asked, choose "[2] Power off and restart the VM" in the setup tool and press <enter> in the second terminal as soon as the VM has been re-created; answer with user/password "ovirt" and hit <enter> as long as the message "Make sure virtmanager is reachable..." appears; when asked for the root password of the hosted engine VM, enter it twice and wait a while (~10min)

9. 
