# kickstart-ovirt-with-gluster
Automate most of a ovirt-with-gluster-and-hosted-engine setup by using kickstart and just a bunch of scripts

*Intention*
For a datacenter-in-a-box setup at home, I wanted to use a virtualization solution being hosted as a all-in-one on a single machine with no need for any external storage (like a NAS box), capable of nested virtualization.

oVirt hosted engine with gluster seemed to be the right solution, and I found Jason Brooks' blog posts http://community.redhat.com/blog/2014/10/up-and-running-with-ovirt-3-5/ and http://community.redhat.com/blog/2014/11/up-and-running-with-ovirt-3-5-part-two/ achieving exactly this.

To be able to repeat the same setup even after a few month or years when it is time to upgrade my hardware for example, I wanted to pack all those answer files and commands in a single kickstart file for easier use and maintenance.

Since I am using my individual defaults like networks and MAC addresses, this setup is not flexible at all unless you modify the files yourselve, but on the other hand you get an out-of-the-box running oVirt environment without going through all the tries and failures I went through :-)

As in the meantime oVirt 3.5.1 supports also RHEL 7 as the hosted engine OS, I changed that in Jason's setup and also changed the required nodes for the gluster cluster to two instead of 3; that's because I didn't want to run several hypervisors in my celaar 24x7, but only one, which should be extended by another one for migration purposes only, namely when I want to upgrade my server to a new hardware.


*Defaults*
admin/internal network: 172.21.0.0/24
DMZ network: 172.19.0.0/24
public network: 192.168.178.0/24 via DHCP from my DSL router
