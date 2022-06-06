Backport Debian packages from unstable to Debian Bullseye
=========================================================

Follow the below directions (based on https://wiki.debian.org/SimpleBackportCreation) to backport a Debian package from unstable to Debian Bullseye. The build occurs within docker, and the resultant deb packages can be found in the `build` directory after a successful build.

---

### **Enter build environment**
```
$ make shell
make shell 
docker-compose run --rm debian-backport bash
Creating network "debian-backport_default" with the default driver
Building debian-backport
...
Creating debian-backport_debian-backport_run ... done
root@eb38da7ddda2:/backport/build#
```

### **Find the version of your package in unstable (https://www.debian.org/distrib/packages may be helpful)**
```
root@eb38da7ddda2:/backport/build# # replace `wget` with your package name
root@eb38da7ddda2:/backport/build# #rmadison wget --architecture source
root@eb38da7ddda2:/backport/build# #rmadison wget --architecture all
root@eb38da7ddda2:/backport/build# rmadison wget
wget       | 1.16-1+deb8u5  | oldoldoldstable    | source, amd64, armel, armhf, i386
wget       | 1.18-5+deb9u3  | oldoldstable       | source, amd64, arm64, armel, armhf, i386, mips, mips64el, mipsel, ppc64el, s390x
wget       | 1.18-5+deb9u3  | oldoldstable-debug | source
wget       | 1.20.1-1.1     | oldstable          | source, amd64, arm64, armel, armhf, i386, mips, mips64el, mipsel, ppc64el, s390x
wget       | 1.21-1+deb11u1 | stable             | source, amd64, arm64, armel, armhf, i386, mips64el, mipsel, ppc64el, s390x
wget       | 1.21-1+deb11u1 | stable-debug       | source
wget       | 1.21.3-1       | testing            | source, arm64, armel, armhf, i386, mips64el, mipsel, ppc64el, s390x
wget       | 1.21.3-1       | unstable           | source
wget       | 1.21.3-1       | unstable-debug     | source
wget       | 1.21.3-1+b1    | testing            | amd64
wget       | 1.21.3-1+b1    | unstable           | arm64, armel, armhf, i386, mips64el, mipsel, ppc64el, s390x
wget       | 1.21.3-1+b2    | unstable           | amd64
```

### **Download the sources**
```
root@eb38da7ddda2:/backport/build# apt source wget=1.21.3-1
Reading package lists... Done
Need to get 5144 kB of source archives.
Get:1 http://deb.debian.org/debian unstable/main wget 1.21.3-1 (dsc) [2167 B]
Get:2 http://deb.debian.org/debian unstable/main wget 1.21.3-1 (tar) [5080 kB]
Get:3 http://deb.debian.org/debian unstable/main wget 1.21.3-1 (asc) [854 B]
Get:4 http://deb.debian.org/debian unstable/main wget 1.21.3-1 (diff) [60.7 kB]
Fetched 5144 kB in 4s (1375 kB/s)
dpkg-source: info: extracting wget in wget-1.21.3
dpkg-source: info: unpacking wget_1.21.3.orig.tar.gz
dpkg-source: info: unpacking wget_1.21.3-1.debian.tar.xz
dpkg-source: info: using patch list from debian/patches/series
dpkg-source: info: applying wget-doc-remove-usr-local-in-sample.wgetrc
dpkg-source: info: applying wget-doc-remove-usr-local-in-wget.texi
dpkg-source: info: applying wget-passive_ftp-default
W: Download is performed unsandboxed as root as file 'wget_1.21.3-1.dsc' couldn't be accessed by user '_apt'. - pkgAcquire::Run (13: Permission denied)
```

### **Install build dependencies**
```
root@eb38da7ddda2:/backport/build# # answer Y to the prompt
root@eb38da7ddda2:/backport/build# cd wget-*
root@eb38da7ddda2:/backport/build/wget-1.21.3# mk-build-deps --install --remove
...
Setting up wget-build-deps (1.21.3-1) ...
Processing triggers for man-db (2.10.1-1~bpo11+1) ...
Processing triggers for libc-bin (2.31-13+deb11u3) ...
```

### **Add a backport changelog**
```
root@eb38da7ddda2:/backport/build/wget-1.21.3# # Press RETURN when prompted
root@eb38da7ddda2:/backport/build/wget-1.21.3# dch --bpo "backport wget-1.21.3"
dch warning: neither DEBEMAIL nor EMAIL environment variable is set
dch warning: building email address from username and FQDN
dch: Did you see those 2 warnings?  Press RETURN to continue...
```

### **Commit new changes**
```
root@eb38da7ddda2:/backport/build/wget-1.21.3# # enter a patch name like `backport.patch`
root@eb38da7ddda2:/backport/build/wget-1.21.3# # edit the description in your editor of choice
root@eb38da7ddda2:/backport/build/wget-1.21.3# dpkg-source --commit
dpkg-source: info: using patch list from debian/patches/series
dpkg-source: info: local changes detected, the modified files are:
 wget-1.21.3/wget-build-deps_1.21.3-1_amd64.buildinfo
 wget-1.21.3/wget-build-deps_1.21.3-1_amd64.changes
Enter the desired patch name: backport.patch

Select an editor.  To change later, run 'select-editor'.
  1. /usr/bin/vim.tiny
  2. /bin/ed

Choose 1-2 [1]: 1
dpkg-source: info: local changes have been recorded in a new patch: wget-1.21.3/debian/patches/backport.patch
```

### **Build without GPG signing the package**
```
root@eb38da7ddda2:/backport/build/wget-1.21.3# # DEB_BUILD_OPTIONS='parallel=4 nocheck' dpkg-buildpackage -us -uc
root@eb38da7ddda2:/backport/build/wget-1.21.3# dpkg-buildpackage -us -uc
...
dpkg-genchanges: info: not including original source code in upload
 dpkg-source --after-build .
dpkg-buildpackage: info: binary and diff upload (original source NOT included)
```

### **Show built packages and cleanup build environment**
```
root@eb38da7ddda2:/backport/build/wget-1.21.3# cd ..
root@eb38da7ddda2:/backport/build# ls -al *.deb
-rw-r--r-- 1 root root 696644 Jun  7 13:03 wget-dbgsym_1.21.3-1~bpo11+1_amd64.deb
-rw-r--r-- 1 root root 984916 Jun  7 13:03 wget_1.21.3-1~bpo11+1_amd64.deb
root@eb38da7ddda2:/backport/build# exit
exit
$ make docker-compose-down 
docker-compose down
Removing network debian-backport_default
$ ls build
wget-1.21.3                            wget_1.21.3-1~bpo11+1.debian.tar.xz  wget_1.21.3.orig.tar.gz
wget_1.21.3-1~bpo11+1_amd64.buildinfo  wget_1.21.3-1~bpo11+1.dsc            wget_1.21.3.orig.tar.gz.asc
wget_1.21.3-1~bpo11+1_amd64.changes    wget_1.21.3-1.debian.tar.xz          wget-dbgsym_1.21.3-1~bpo11+1_amd64.deb
wget_1.21.3-1~bpo11+1_amd64.deb        wget_1.21.3-1.dsc                    wget-udeb_1.21.3-1~bpo11+1_amd64.udeb
```

---
## Troubleshooting
* the build may fail due to dependencies from unstable, so you'll have to backport dependencies and install them in the build environment before being able to build your package successfully
* sometimes there will be patches that are no longer valid, or other code anomolies that break the build - you'll have to debug things yourself
