
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
| 2.1          | Configure Server Services                                    | ⏳       |
| 2.1.1        | Ensure autofs services are not in use                        | ✅       |
| 2.1.2        | Ensure avahi-daemon services are not in use                  | ✅       |
| 2.1.3        | Ensure dhcp server services are not in use                   | ✅       |
| 2.1.4        | Ensure dns server services are not in use                    | ✅       |
| 2.1.5        | Ensure dnsmasq server services are not in use                | ✅       |
| 2.1.6        | Ensure ftp server services are not in use                    | ✅       |
| 2.1.7        | Ensure ldap server services are not in use                   | ✅       |
| 2.1.8        | Ensure message access server services are not in use                  | ✅       |
| 2.1.9        | Ensure nfs server services are not in use                    | ✅       |
| 2.1.10       | Ensure nis services are not in use                          | ✅       |
| 2.1.11       | Ensure print server services are not in use                    | ✅       |
| 2.1.12       | Ensure rpcbind server services are not in use                  | ✅       |
| 2.1.13       | Ensure rsync services are not in use                   | ✅       |
| 2.1.14       | Ensure samba services are not in use                   | ✅       |
| 2.1.15       | Ensure snmp services are not in use                   | ✅       |
| 2.1.16       | Ensure tftp server services are not in use                   | ✅       |
| 2.1.17       | Ensure web proxy services are not in use                        | ✅       |
| 2.1.18       | Ensure web server services are not in use                   | ✅       |
| 2.1.19       | Ensure xinetd services are not in use                        | ✅       |
| 2.1.20       | Ensure X Windows services are not in use                        | ✅       |
| 2.1.21       | Ensure Ensure mail transfer agent is configured for local-only mode | ✅       |
| 2.1.22       | Ensure only approved services are listening on the network interface | ✅  |
| 2.2          | Configure Client services                                 | ⏳       |
| 2.2.1        | Ensure NIS client services are not in use                   | ✅       |

---
