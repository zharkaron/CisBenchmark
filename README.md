# This repo is made to be used as a CIA (CIS) benchmark for Linux, windows, and macOS.

| ID           | Title                                                        | Status   |
|--------------|--------------------------------------------------------------|----------|
| 1            | Initial Setup                                                | ✅       |
| 1.1          | Filesystem                                                   | ✅       |
| 1.1.1        | Configure Filesystem Kernel Modules                          | ✅       |
| 1.1.1.1      | Ensure cramfs kernel module is not available                 | ✅       |
| 1.1.1.2      | Ensure freevxfs kernel module is not available               | ✅       |
| 1.1.1.3      | Ensure hfs kernel module is not available                    | ✅       |
| 1.1.1.4      | Ensure hfsplus kernel module is not available                | ✅       |
| 1.1.1.5      | Ensure jffs2 kernel module is not available                  | ✅       |
| 1.1.1.6      | Ensure squashfs kernel module is not available               | ✅       |
| 1.1.1.7      | Ensure udf kernel module is not available                    | ✅       |
| 1.1.1.8      | Ensure usb-storage kernel module is not available            | ✅       |
| 1.1.2        | Configure Filesystem Partitions                              | ✅       |
| 1.1.2.1      | Configure /tmp                                               | ✅       |
| 1.1.2.1.1    | Ensure /tmp is separate partition                            | ✅       |
| 1.1.2.1.2    | Ensure nodev option set on /tmp partition                    | ✅       |
| 1.1.2.1.3    | Ensure nosuid option is set on /tmp partition                | ✅       |
| 1.1.2.1.4    | Ensure noexec option is set on /tmp partition                | ✅       |
| 1.1.2.2      | Configure /dev/shm                                           | ✅       |
| 1.1.2.2.1    | Verify /dev/shm is mounted as a separate partition           | ✅       |
| 1.1.2.2.2    | Ensure nodev option is set on /dev/shm partition             | ✅       |
| 1.1.2.2.3    | Ensure nosuid option is set on /dev/shm partition            | ✅       |
| 1.1.2.2.4    | Ensure noexec option set on /dev/shm partition               | ✅       |
| 1.1.2.3      | Configure /home                                              | ✅       |
| 1.1.2.3.1    | Ensure separate partition exists for /home                   | ✅       |
| 1.1.2.3.2    | Ensure nodev option set on /home partition                   | ✅       |
| 1.1.2.3.3    | Ensure nosuid option is set on /home partition               | ✅       |
| 1.1.2.4      | Configure /var                                               | ✅       |
| 1.1.2.4.1    | Ensure separate partition exists for /var                    | ✅       |
| 1.1.2.4.2    | Ensure nodev option is set on /var partition                 | ✅       |
| 1.1.2.4.3    | Ensure nosuid option is set on /var partition                | ✅       |
| 1.1.2.5      | Configure /var/tmp                                           | ✅       |
| 1.1.2.5.1    | Ensure /var/tmp is mounted as a separate partition           | ✅       |
| 1.1.2.5.2    | Ensure nodev option is set on /var/tmp partition             | ✅       |
| 1.1.2.5.3    | Ensure nosuid option is set on /var/tmp partition            | ✅       |
| 1.1.2.5.4    | Ensure noexec option is set on /var/tmp partition            | ✅       |
| 1.1.2.6      | Configure /var/log                                           | ✅       |
| 1.1.2.6.1    | Ensure separate partition exists for /var/log                | ✅       |
| 1.1.2.6.2    | Ensure nodev option is set on /var/log partition             | ✅       |
| 1.1.2.6.3    | Ensure nosuid option is set on /var/log partition            | ✅       |
| 1.1.2.6.4    | Ensure noexec option is set on /var/log partition            | ✅       |
| 1.1.2.7      | Configure /var/log/audit                                     | ✅       |
| 1.1.2.7.1    | Ensure separate partition exists for /var/log/audit          | ✅       |
| 1.1.2.7.2    | Ensure nodev option is set on /var/log/audit partition       | ✅       |
| 1.1.2.7.3    | Ensure nosuid option is set on /var/log/audit partition      | ✅       |
| 1.1.2.7.4    | Ensure noexec option is set on /var/log/audit partition      | ✅       |
| 1.2          | Package Management                                           | ✅       |
| 1.2.1        | Configure Package Repositories                               | ✅       |
| 1.2.1.1      | Ensure GPG keys are configured                               | ✅       |
| 1.2.1.2      | Ensure package manager repositories are configured           | ✅       |
| 1.2.2        | Configure Packege Updates                                    | ✅       |
| 1.2.2.1      | Ensure updates, patches, and additional security software are installed | ✅ |
| 1.3          | Mandatory Access Control                                     | ✅       |
| 1.3.1        | Configure AppArmor                                           | ✅       |
| 1.3.1.1      | Ensure AppArmor is installed                                 | ✅       |
| 1.3.1.2      | Ensure AppArmor is enabled in the bootloader configuration   | ✅       |
| 1.3.1.3      | Ensure AppArmor profiles are in enforce mode                 | ✅       |
| 1.3.1.4      | Ensure all AppArmor profiles are in enforcing                | ✅       |
| 1.4          | Configure Bootloader                                         | ✅       |
| 1.4.1        | Ensure bootloader password is set                            | ✅       |
| 1.4.2        | Ensure access to bootloader config is configured             | ✅       |
| 1.5          | Configure additional Process hardening                       | ✅       |
| 1.5.1        | Ensure address space layout randomization is enabled         | ✅       |
| 1.5.2        | Ensure ptrace_score is restricted                            | ✅       |
| 1.5.3        | Ensure core dumps are restricted                             | ✅       |
| 1.5.4        | Ensure prelink is not installed                              | ✅       |
| 1.5.5        | Ensure Automatic Error Reporting is not enabled              | ✅       |
| 1.6          | Configure Command Line Warning Banner                        | ✅       |
| 1.6.1        | Ensure message of the day is configured properly             | ✅       |
| 1.6.2        | Ensure local login warning banner is configured properly      | ✅       |
| 1.6.3        | Ensure remote login warning banner is configured properly     | ✅       |
| 1.6.4        | Ensure access to /etc/motd is configured                     | ✅       |
| 1.6.5        | Ensure access to /etc/issue is configured                    | ✅       |
| 1.6.6        | Ensure access to /etc/issue.net is configured                | ✅       |
| 1.7          | Configure GNOME Display Manager                              | ✅       |
| 1.7.1        | Ensure GDM is removed                                        | ✅       |
| 1.7.2        | Ensure GDM login banner is configured                        | ✅       |
| 1.7.3        | Ensure GDM disable-user-list option is enabled               | ✅       |
| 1.7.4        | Ensure GDM screen locks when the user is idle                | ✅       |
| 1.7.5        | Ensure GDM screen locks cannot be overridden                 | ✅       |
| 1.7.6        | Ensure GDM automatic mounting of removable media is disabled | ✅       |
| 1.7.7        | Ensure GDM disabling automatic mounting of removable media is not overridden | ✅ |
| 1.7.8        | Ensure GDM autorun-never is enabled                          | ✅       |
| 1.7.9        | Ensure GDM autorun-never cannot be overridden                | ✅       |
| 1.7.10       | Ensure XDCMP is disabled                                     | ✅       |
| 2            | Services                                                     | ⏳       |
| 2.1          | Configure Server Services                                    | ✅       |
| 2.1.1        | Ensure autofs services are not in use                        | ✅       |
| 2.1.2        | Ensure avahi-daemon services are not in use                  | ✅       |
| 2.1.3        | Ensure dhcp server services are not in use                   | ✅       |
| 2.1.4        | Ensure dns server services are not in use                    | ✅       |
| 2.1.5        | Ensure dnsmasq server services are not in use                | ✅       |
| 2.1.6        | Ensure ftp server services are not in use                    | ✅       |
| 2.1.7        | Ensure ldap server services are not in use                   | ✅       |
| 2.1.8        | Ensure message access server services are not in use         | ✅       |
| 2.1.9        | Ensure nfs server services are not in use                    | ✅       |
| 2.1.10       | Ensure nis services are not in use                           | ✅       |
| 2.1.11       | Ensure print server services are not in use                  | ✅       |
| 2.1.12       | Ensure rpcbind server services are not in use                | ✅       |
| 2.1.13       | Ensure rsync services are not in use                         | ✅       |
| 2.1.14       | Ensure samba services are not in use                         | ✅       |
| 2.1.15       | Ensure snmp services are not in use                          | ✅       |
| 2.1.16       | Ensure tftp server services are not in use                   | ✅       |
| 2.1.17       | Ensure web proxy services are not in use                     | ✅       |
| 2.1.18       | Ensure web server services are not in use                    | ✅       |
| 2.1.19       | Ensure xinetd services are not in use                        | ✅       |
| 2.1.20       | Ensure X Windows services are not in use                     | ✅       |
| 2.1.21       | Ensure Ensure mail transfer agent is configured for local-only mode | ✅       |
| 2.1.22       | Ensure only approved services are listening on the network interface | ✅  |
| 2.2          | Configure Client services                                    | ✅       |
| 2.2.1        | Ensure NIS client services are not in use                    | ✅       |
| 2.2.2        | Ensure rsh client services are not in use                    | ✅       |
| 2.2.3        | Ensure talk client services are not in use                   | ✅       |
| 2.2.4        | Ensure telnet client services are not in use                 | ✅       |
| 2.2.5        | Ensure ldap client services are not in use                   | ✅       |
| 2.2.6        | Ensure ftp client services are not in use                    | ✅       |
| 2.3          | Configure Time Syncehronization                              | ✅       |
| 2.3.1        | Ensure time synchronization is in use                        | ✅       |
| 2.3.1.1      | Ensure a single time syncronization daemon is in use         | ✅       |
| 2.3.2        | Configure systemd-timesyncd                                  | ✅       |
| 2.3.2.1      | Ensure systemd-timesyncd configured with authorized timeserver | ✅       |
| 2.3.2.2      | Ensure systemd-timesyncd is enabled                         | ✅       |
| 2.3.3        | Configure chrony                                           | ✅       |
| 2.3.3.1      | Ensure chrony is configured with authorized timeserver   | ✅       |
| 2.3.3.2      | Ensure chrony is running as user_chrony                   | ✅       |
| 2.4          | Job Schedulers                                         | ✅       |
| 2.4.1        | Configure cron                                         | ✅       |
| 2.4.1.1      | Ensure cron daemon is enabled and active                 | ✅       |
| 2.4.1.2      | Ensure permissions on /etc/crontab are configured     | ✅       |
| 2.4.1.3      | Ensure permissions on /etc/cron.hourly are configured | ✅       |
| 2.4.1.4      | Ensure permissions on /etc/cron.daily are configured  | ✅       |
| 2.4.1.5   | Ensure permissions on /etc/cron.weekly are configured | ✅       |
| 2.4.1.6      | Ensure permissions on /etc/cron.monthly are configured | ✅       |
| 2.4.1.7     | Ensure permissions on /etc/cron.d are configured | ✅       |
| 2.4.1.8      | Ensure crontab is restricted to authorized users | ✅       |
| 2.4.2        | Configure at                                         | ✅       |
| 2.4.2.1      | Ensure at is restricted to authorized users | ✅       |
| 3            | Network                                                     | ✅       |
| 3.1          | Configure Network Devices                                   | ✅       |
| 3.1.1        | Ensure IPv6 status is identified                            | ✅       |
| 3.1.2        | Ensure wireless interfaces are disabled                     | ✅       |
| 3.1.3        | Ensure Bluetooth services are not in use                    | ✅       |
| 3.2          | Configure Network Kernel Modules                            | ✅       |
| 3.2.1        | Ensure dccp kernel module is not available                  | ✅       |
| 3.2.2        | Ensure tipc kernel module is not available                  | ✅       |
| 3.2.3        | Ensure rds kernel module is not available                   | ✅       |
| 3.2.4        | Ensure sctp kernel module is not available                  | ✅       |
| 3.3          | Configure Network Kernel Parameters                         | ✅       |
| 3.3.1        | Ensure ip forwarding is disabled                            | ✅       |
| 3.3.2        | Ensure packet redirect sending is disabled                  | ✅       |
| 3.3.3        | Ensure bogus icmp responses are ignored                     | ✅       |
| 3.3.4        | Ensure broadcast icmp requests are ignored                  | ✅       |
| 3.3.5        | Ensure icmp redirects are not accepted                      | ✅       |
| 3.3.6        | Ensure secure icmp redirects are not accepted               | ✅       |
| 3.3.7        | Ensure reverse path filtering is enabled                    | ✅       |
| 3.3.8        | Ensure source routed packets are not accepted               | ✅       |
| 3.3.9        | Ensure suspicious packets are logged                        | ✅       |
| 3.3.10       | Ensure tcp syn cookies are enabled                           | ✅       |
| 3.3.11       | Ensure ipv6 router advertisements are not accepted          | ✅       |
| 4            | Host Based Firewall                                         | ✅       |
| 4.1          | Configure Uncomplicated Firewall (UFW)                      | ✅       |
| 4.1.1        | Ensure ufw is installed                                     | ✅       |
| 4.1.2        | Ensure iptables-persistent is not installed with ufw       | ✅       |
| 4.1.3        | Ensure ufw service is enabled                               | ✅       |
| 4.1.4        | Ensure ufw loopback traffic is configured                   | ✅       |
| 4.1.5        | Ensure ufw outbound connections are configured              | ✅       |
| 4.1.6        | Ensure ufw firewall rules exist for all open ports          | ✅       |
| 4.1.7        | Ensure ufw default deny firewall policy is configured       | ✅       |
| 4.2          | Configure nftables                                         | ✅       |
| 4.2.1        | Ensure nftables is installed                               | ✅       |
| 4.2.2        | Ensure ufw is uninstalled or disabled with nftables         | ✅       |
| 4.2.3        | Ensure iptables are flushed with nftables                   | ✅       |
| 4.2.4        | Ensure a nftables table exists                              | ✅       |
| 4.2.5        | Ensure a nftables base chain exists                         | ✅       |
| 4.2.6        | Ensure nftables loopback traffic is configured              | ✅       |
| 4.2.7        | Ensure nftables outbound and established connections configured | ✅   |
| 4.2.8        | Ensure nftables default deny firewall policy is configured  | ✅       |
| 4.2.9        | Ensure nftables service is enabled                          | ✅       |
| 4.2.10       | Ensure nftables rules are permanent                         | ✅       |
| 4.3          | Configure iptables                                         | ✅       |
| 4.3.1        | Configure iptables software                                 | ✅       |
| 4.3.1.1      | Ensure iptables packages are installed                      | ✅       |
| 4.3.1.2      | Ensure nftables is not installed with iptables             | ✅       |
| 4.3.1.3      | Ensure ufw is uninstalled or disabled with iptables         | ✅       |
| 4.3.2        | Configure IPv4 iptables                                    | ✅       |
| 4.3.2.1      | Ensure iptables default deny firewall policy is configured | ✅       |
| 4.3.2.2      | Ensure iptables loopback traffic is configured             | ✅       |
| 4.3.2.3      | Ensure iptables outbound and established connections configured | ✅    |
| 4.3.2.4      | Ensure iptables firewall rules exist for all open ports     | ✅       |
| 4.3.3        | Configure IPv6 iptables                                    | ✅       |
| 4.3.3.1      | Ensure ip6tables default deny firewall policy is configured | ✅       |
| 4.3.3.2      | Ensure ip6tables loopback traffic is configured            | ✅       |
| 4.3.3.3      | Ensure ip6tables outbound and established connections configured | ✅    |
| 4.3.3.4      | Ensure ip6tables firewall rules exist for all open ports    | ✅       |

---

