#!/usr/bin/env bash
#
# coding: utf-8
# author: liuchao
# date: 2022.04.09
# usage: deploy kvm environment.


# check current system =? CentOS
# The current script supports the use of the centos distribution, 
# and centos 7 is recommended; the script execution environment is bash
if [ -f /etc/redhat-release ];then
	echo "$(cat /etc/redhat-release)"
else
  echo "this system is not CentOS"
  exit 1
fi

function initial_environment() {
  # set off firewalld & selinux
  systemctl disable --now firewalld
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
  # configure yum repo files
  mkdir -p /etc/yum.repos.d/repobak; mv /etc/yum.repos.d/* /etc/yum.repos.d/repobak/
  curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
  curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
  yum clean all; yum makecache
  # install require software
  yum -y install vim net-tools bridge-utils qemu-kvm libvirt virt-install libguestfs libguestfs-tools
  systemctl enable --now libvirtd.service
}

function initial_directory() {
  mkdir -p /kvm/{vdisks,isos,modify}
  if [ ! -f /kvm/isos/CentOS-7-x86_64-Minimal-2009.iso ];then
    curl -o /kvm/isos/CentOS-7-x86_64-Minimal-2009.iso https://mirrors.ustc.edu.cn/centos/7.9.2009/isos/x86_64/CentOS-7-x86_64-Minimal-2009.iso
  fi
}

function upgrade_kernel() {
  # upgrade kernel
  yum -y update --exclude=kernel*
  if [ ! -f kernel-lt-5.4.188-1.el7.elrepo.x86_64.rpm ];then
    curl -o kernel-lt-5.4.188-1.el7.elrepo.x86_64.rpm https://elrepo.org/linux/kernel/el7/x86_64/RPMS/kernel-lt-5.4.188-1.el7.elrepo.x86_64.rpm
  fi
  if [ ! -f kernel-lt-devel-5.4.188-1.el7.elrepo.x86_64.rpm ];then
    curl -o kernel-lt-devel-5.4.188-1.el7.elrepo.x86_64.rpm https://elrepo.org/linux/kernel/el7/x86_64/RPMS/kernel-lt-devel-5.4.188-1.el7.elrepo.x86_64.rpm
  fi
  yum -y localinstall kernel-lt-*
  grub2-set-default 0 && grub2-mkconfig -o /etc/grub2.cfg
  grubby --args="user_namespace.enable=1" --update-kernel="$(grubby --default-kernel)"
  modprobe -a kvm
}

initial_environment
initial_directory
upgrade_kernel

# reboot machines, continue load kernel kvm module
reboot
