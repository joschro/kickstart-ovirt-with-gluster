# kickstart-ovirt-with-gluster
Automate most of a ovirt-with-gluster-and-hosted-engine setup by using kickstart and just a bunch of scripts

*Intention*
For a datacenter-in-a-box setup at home, I wanted to use a virtualization solution being hosted as a all-in-one on a single machine with no need for any external storage (like a NAS box), capable of nested virtualization.

oVirt hosted engine with gluster seemed to be the right solution, and I found Jason Brooks' blog posts http://community.redhat.com/blog/2014/10/up-and-running-with-ovirt-3-5/ and http://community.redhat.com/blog/2014/11/up-and-running-with-ovirt-3-5-part-two/ achieving exactly this.

To be able to repeat the same setup even after a few month or years when it is time to upgrade my hardware for example, I wanted to pack all those answer files and commands in a single kickstart file for easier use and maintenance.

Since I am using my individual defaults like networks and MAC addresses, this setup is not flexible at all unless you modify the files yourselve, but on the other hand you get an out-of-the-box running oVirt environment without going through all the tries and failures I went through :-)

As in the meantime oVirt 3.5.1 supports also RHEL 7 as the hosted engine OS, I changed that in Jason's setup and also changed the required nodes for the gluster cluster to two instead of 3; that's because I didn't want to run several hypervisors in my celaar 24x7, but only one, which should be extended by another one for migration purposes only, namely when I want to upgrade my server to a new hardware.


<b>Defaults/Requirements</b><br><br>
Physical networks:<br>
admin/internal network: 172.21.0.0/24 ("ovirtmgmt")

DMZ network: 172.19.0.0/24 ("DMZ")

public network: 192.168.178.0/24 ("Public") via DHCP from DSL router


IPs:

virtstorage: 172.21.0.99/24 (controlled by ctdb HA failover)

virtmanager: 172.21.0.100/24

virthost01: 172.21.0.101/24

virthost02: 172.21.0.102/24

virthost03: 172.21.0.103/24


*Workflow*

1. Prepare USB stick by downloading CentOS 7 ISO image (http://mirrors.kernel.org/centos/7.1.1503/isos/x86_64/CentOS-7-x86_64-Minimal-1503-01.iso (636MB) or http://mirrors.kernel.org/centos/7.1.1503/isos/x86_64/CentOS-7-x86_64-Everything-1503-01.iso (7GB)) and write it to the USB stick using dd (or any other tool as described in http://wiki.centos.org/HowTos/InstallFromUSBkey)

2. Prepare your kickstart file with the gen-ks-from-template.sh and modify where needed (e.g. network devices, one instead of default two harddisks etc.); then upload it to any place that can be reached from your new server via HTTP, NFS or similar.

3. Boot your server from the USB key (you may need to press F11 or F12 during BIOS startup to bring up the boot device menu) and choose "Installation" with the arrow keys and then press <TAB>; add "ks=<URL-to-your-upload-kickstart-file" to the boot command line to point the installer to your kickstart file and press <Enter>.

4. After installation has finished and server has rebooted, you are prompted for the harddisk encryption password (1234567890); after that, login with "root" and run "/root/step_1_on_virthost01_hosted-engine-deploy.sh"

5. When asked, run "/root/step_1.1_on_virthost01_hosted-engine-configure.sh" in a second terminal window (switch to a new one with <Alt-F2> and login with "root" again; switch between terminals with <Alt-F1> and <Alt-F2>).

6. When asked, run "/root/step_1.2_on_virtmanager_hosted-engine-setup.sh"

7. 
