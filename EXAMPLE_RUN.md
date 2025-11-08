```
ansible-playbook k8s_cluster_kvm.yml

PLAY [Provision KVM infrastructure for Kubernetes cluster] *************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [localhost]

TASK [Load all OS-specific variables for KVM host] *********************************************************************
ok: [localhost]

TASK [kvm_host : Ensure virtualization packages are installed] *********************************************************
ok: [localhost]

TASK [kvm_host : Configure libvirt to use the iptables firewall backend] ***********************************************
ok: [localhost]

TASK [kvm_host : Configure libvirtd to trust the 'libvirt' group] ******************************************************
ok: [localhost] => (item={'key': 'unix_sock_group', 'value': '"libvirt"'})
ok: [localhost] => (item={'key': 'unix_sock_rw_perms', 'value': '"0770"'})
ok: [localhost] => (item={'key': 'auth_unix_rw', 'value': '"none"'})

TASK [kvm_host : Ensure libvirt service is active and enabled] *********************************************************
ok: [localhost]

TASK [provision_k8s_vms : Run script to find the correct ssh public key] ***********************************************
ok: [localhost]

TASK [provision_k8s_vms : Set ssh_pub_key_path fact from script output] ************************************************
ok: [localhost]

TASK [provision_k8s_vms : Run creation tasks] **************************************************************************
included: /home/your_user/repos/github.com/your_user74/ansible_kvm/roles/provision_k8s_vms/tasks/present.yml for localhost

TASK [provision_k8s_vms : Set internal SSH key variable from user path] ************************************************
ok: [localhost]

TASK [provision_k8s_vms : Define the custom libvirt network from XML template] *****************************************
changed: [localhost]

TASK [provision_k8s_vms : Ensure the custom libvirt network is active and set to autostart] ****************************
changed: [localhost]

TASK [provision_k8s_vms : Download Ubuntu KVM Cloud image] *************************************************************
ok: [localhost]

TASK [provision_k8s_vms : Create dedicated disk images for each VM] ****************************************************
changed: [localhost] => (item={'name': 'k8s-master', 'disk_gb': 25, 'mem_gb': 4, 'vcpus': 2})
changed: [localhost] => (item={'name': 'k8s-worker1', 'disk_gb': 20, 'mem_gb': 2, 'vcpus': 2})
changed: [localhost] => (item={'name': 'k8s-worker2', 'disk_gb': 20, 'mem_gb': 2, 'vcpus': 2})

TASK [provision_k8s_vms : Create cloud-init temporary directories] *****************************************************
ok: [localhost] => (item={'name': 'k8s-master', 'disk_gb': 25, 'mem_gb': 4, 'vcpus': 2})
ok: [localhost] => (item={'name': 'k8s-worker1', 'disk_gb': 20, 'mem_gb': 2, 'vcpus': 2})
ok: [localhost] => (item={'name': 'k8s-worker2', 'disk_gb': 20, 'mem_gb': 2, 'vcpus': 2})

TASK [provision_k8s_vms : Create user-data file for each VM] ***********************************************************
ok: [localhost] => (item={'name': 'k8s-master', 'disk_gb': 25, 'mem_gb': 4, 'vcpus': 2})
ok: [localhost] => (item={'name': 'k8s-worker1', 'disk_gb': 20, 'mem_gb': 2, 'vcpus': 2})
ok: [localhost] => (item={'name': 'k8s-worker2', 'disk_gb': 20, 'mem_gb': 2, 'vcpus': 2})

TASK [provision_k8s_vms : Create meta-data file for each VM] ***********************************************************
ok: [localhost] => (item={'name': 'k8s-master', 'disk_gb': 25, 'mem_gb': 4, 'vcpus': 2})
ok: [localhost] => (item={'name': 'k8s-worker1', 'disk_gb': 20, 'mem_gb': 2, 'vcpus': 2})
ok: [localhost] => (item={'name': 'k8s-worker2', 'disk_gb': 20, 'mem_gb': 2, 'vcpus': 2})

TASK [provision_k8s_vms : Create cloud-init ISO for each VM] ***********************************************************
changed: [localhost] => (item={'name': 'k8s-master', 'disk_gb': 25, 'mem_gb': 4, 'vcpus': 2})
changed: [localhost] => (item={'name': 'k8s-worker1', 'disk_gb': 20, 'mem_gb': 2, 'vcpus': 2})
changed: [localhost] => (item={'name': 'k8s-worker2', 'disk_gb': 20, 'mem_gb': 2, 'vcpus': 2})

TASK [provision_k8s_vms : Generate libvirt XML definitions in-memory] **************************************************
ok: [localhost] => (item={'name': 'k8s-master', 'disk_gb': 25, 'mem_gb': 4, 'vcpus': 2})
ok: [localhost] => (item={'name': 'k8s-worker1', 'disk_gb': 20, 'mem_gb': 2, 'vcpus': 2})
ok: [localhost] => (item={'name': 'k8s-worker2', 'disk_gb': 20, 'mem_gb': 2, 'vcpus': 2})

TASK [provision_k8s_vms : Define the Kubernetes VMs from generated XML] ************************************************
ok: [localhost] => (item=<domain type='kvm'>
  <name>k8s-master</name>
  <memory unit='GiB'>4</memory>
  <currentMemory unit='GiB'>4</currentMemory>
  <vcpu placement='static'>2</vcpu>
  <os>
    <type arch='x86_64' machine='pc-q35-8.1'>hvm</type>
  </os>
  <features>
    <acpi/>
    <apic/>
  </features>
  <cpu mode='host-model' check='partial'/>
  <clock offset='utc'>
    <timer name='rtc' tickpolicy='catchup'/>
    <timer name='pit' tickpolicy='delay'/>
    <timer name='hpet' present='no'/>
  </clock>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>destroy</on_crash>
  <pm>
    <suspend-to-mem enabled='no'/>
    <suspend-to-disk enabled='no'/>
  </pm>
  <devices>
    <emulator>/usr/bin/qemu-system-x86_64</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='/var/lib/libvirt/images/k8s-master.qcow2'/>
      <target dev='vda' bus='virtio'/>
      <boot order='1'/>
    </disk>
    <disk type='file' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <source file='/var/lib/libvirt/images/k8s-master-cidata.iso'/>
      <target dev='sda' bus='sata'/>
      <readonly/>
    </disk>
    <controller type='usb' index='0' model='qemu-xhci' ports='15'/>
    <controller type='pci' index='0' model='pcie-root'/>
    <controller type='sata' index='0'/>
    <controller type='virtio-serial' index='0'/>
    <interface type='network'>
      <mac address='52:54:00:ab:cd:0a'/>
      <source network='k8s-net'/>
      <model type='virtio'/>
    </interface>
    <serial type='pty'>
      <target type='isa-serial' port='0'>
        <model name='isa-serial'/>
      </target>
    </serial>
    <console type='pty'>
      <target type='serial' port='0'/>
    </console>
    <input type='tablet' bus='usb'/>
    <input type='mouse' bus='ps2'/>
    <input type='keyboard' bus='ps2'/>
    <memballoon model='virtio'/>
  </devices>
</domain>
)
ok: [localhost] => (item=<domain type='kvm'>
  <name>k8s-worker1</name>
  <memory unit='GiB'>2</memory>
  <currentMemory unit='GiB'>2</currentMemory>
  <vcpu placement='static'>2</vcpu>
  <os>
    <type arch='x86_64' machine='pc-q35-8.1'>hvm</type>
  </os>
  <features>
    <acpi/>
    <apic/>
  </features>
  <cpu mode='host-model' check='partial'/>
  <clock offset='utc'>
    <timer name='rtc' tickpolicy='catchup'/>
    <timer name='pit' tickpolicy='delay'/>
    <timer name='hpet' present='no'/>
  </clock>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>destroy</on_crash>
  <pm>
    <suspend-to-mem enabled='no'/>
    <suspend-to-disk enabled='no'/>
  </pm>
  <devices>
    <emulator>/usr/bin/qemu-system-x86_64</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='/var/lib/libvirt/images/k8s-worker1.qcow2'/>
      <target dev='vda' bus='virtio'/>
      <boot order='1'/>
    </disk>
    <disk type='file' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <source file='/var/lib/libvirt/images/k8s-worker1-cidata.iso'/>
      <target dev='sda' bus='sata'/>
      <readonly/>
    </disk>
    <controller type='usb' index='0' model='qemu-xhci' ports='15'/>
    <controller type='pci' index='0' model='pcie-root'/>
    <controller type='sata' index='0'/>
    <controller type='virtio-serial' index='0'/>
    <interface type='network'>
      <mac address='52:54:00:ab:cd:0b'/>
      <source network='k8s-net'/>
      <model type='virtio'/>
    </interface>
    <serial type='pty'>
      <target type='isa-serial' port='0'>
        <model name='isa-serial'/>
      </target>
    </serial>
    <console type='pty'>
      <target type='serial' port='0'/>
    </console>
    <input type='tablet' bus='usb'/>
    <input type='mouse' bus='ps2'/>
    <input type='keyboard' bus='ps2'/>
    <memballoon model='virtio'/>
  </devices>
</domain>
)
ok: [localhost] => (item=<domain type='kvm'>
  <name>k8s-worker2</name>
  <memory unit='GiB'>2</memory>
  <currentMemory unit='GiB'>2</currentMemory>
  <vcpu placement='static'>2</vcpu>
  <os>
    <type arch='x86_64' machine='pc-q35-8.1'>hvm</type>
  </os>
  <features>
    <acpi/>
    <apic/>
  </features>
  <cpu mode='host-model' check='partial'/>
  <clock offset='utc'>
    <timer name='rtc' tickpolicy='catchup'/>
    <timer name='pit' tickpolicy='delay'/>
    <timer name='hpet' present='no'/>
  </clock>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>destroy</on_crash>
  <pm>
    <suspend-to-mem enabled='no'/>
    <suspend-to-disk enabled='no'/>
  </pm>
  <devices>
    <emulator>/usr/bin/qemu-system-x86_64</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='/var/lib/libvirt/images/k8s-worker2.qcow2'/>
      <target dev='vda' bus='virtio'/>
      <boot order='1'/>
    </disk>
    <disk type='file' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <source file='/var/lib/libvirt/images/k8s-worker2-cidata.iso'/>
      <target dev='sda' bus='sata'/>
      <readonly/>
    </disk>
    <controller type='usb' index='0' model='qemu-xhci' ports='15'/>
    <controller type='pci' index='0' model='pcie-root'/>
    <controller type='sata' index='0'/>
    <controller type='virtio-serial' index='0'/>
    <interface type='network'>
      <mac address='52:54:00:ab:cd:0c'/>
      <source network='k8s-net'/>
      <model type='virtio'/>
    </interface>
    <serial type='pty'>
      <target type='isa-serial' port='0'>
        <model name='isa-serial'/>
      </target>
    </serial>
    <console type='pty'>
      <target type='serial' port='0'/>
    </console>
    <input type='tablet' bus='usb'/>
    <input type='mouse' bus='ps2'/>
    <input type='keyboard' bus='ps2'/>
    <memballoon model='virtio'/>
  </devices>
</domain>
)

TASK [provision_k8s_vms : Ensure the Kubernetes VMs are running] *******************************************************
changed: [localhost] => (item={'name': 'k8s-master', 'disk_gb': 25, 'mem_gb': 4, 'vcpus': 2})
changed: [localhost] => (item={'name': 'k8s-worker1', 'disk_gb': 20, 'mem_gb': 2, 'vcpus': 2})
changed: [localhost] => (item={'name': 'k8s-worker2', 'disk_gb': 20, 'mem_gb': 2, 'vcpus': 2})

TASK [provision_k8s_vms : Wait for VMs to get an IP address] ***********************************************************
FAILED - RETRYING: [localhost]: Wait for VMs to get an IP address (30 retries left).
FAILED - RETRYING: [localhost]: Wait for VMs to get an IP address (29 retries left).
FAILED - RETRYING: [localhost]: Wait for VMs to get an IP address (28 retries left).
FAILED - RETRYING: [localhost]: Wait for VMs to get an IP address (27 retries left).
ok: [localhost] => (item={'name': 'k8s-master', 'disk_gb': 25, 'mem_gb': 4, 'vcpus': 2})
ok: [localhost] => (item={'name': 'k8s-worker1', 'disk_gb': 20, 'mem_gb': 2, 'vcpus': 2})
ok: [localhost] => (item={'name': 'k8s-worker2', 'disk_gb': 20, 'mem_gb': 2, 'vcpus': 2})

TASK [provision_k8s_vms : Add VMs to in-memory inventory] **************************************************************
ok: [localhost] => (item={'changed': False, 'stdout': '192.168.123.168', 'stderr': '', 'rc': 0, 'cmd': "virsh domifaddr k8s-master | grep ipv4 | awk '{print $4}' | cut -d '/' -f1", 'start': '2025-11-07 19:52:48.093001', 'end': '2025-11-07 19:52:48.106712', 'delta': '0:00:00.013711', 'msg': '', 'invocation': {'module_args': {'cmd': "virsh domifaddr k8s-master | grep ipv4 | awk '{print $4}' | cut -d '/' -f1", '_uses_shell': True, 'expand_argument_vars': True, 'stdin_add_newline': True, 'strip_empty_ends': True, '_raw_params': None, 'argv': None, 'chdir': None, 'executable': None, 'creates': None, 'removes': None, 'stdin': None}}, 'stdout_lines': ['192.168.123.168'], 'stderr_lines': [], 'failed': False, 'attempts': 5, 'item': {'name': 'k8s-master', 'disk_gb': 25, 'mem_gb': 4, 'vcpus': 2}, 'ansible_loop_var': 'item'})
ok: [localhost] => (item={'changed': False, 'stdout': '192.168.123.169', 'stderr': '', 'rc': 0, 'cmd': "virsh domifaddr k8s-worker1 | grep ipv4 | awk '{print $4}' | cut -d '/' -f1", 'start': '2025-11-07 19:52:48.304004', 'end': '2025-11-07 19:52:48.318093', 'delta': '0:00:00.014089', 'msg': '', 'invocation': {'module_args': {'cmd': "virsh domifaddr k8s-worker1 | grep ipv4 | awk '{print $4}' | cut -d '/' -f1", '_uses_shell': True, 'expand_argument_vars': True, 'stdin_add_newline': True, 'strip_empty_ends': True, '_raw_params': None, 'argv': None, 'chdir': None, 'executable': None, 'creates': None, 'removes': None, 'stdin': None}}, 'stdout_lines': ['192.168.123.169'], 'stderr_lines': [], 'failed': False, 'attempts': 1, 'item': {'name': 'k8s-worker1', 'disk_gb': 20, 'mem_gb': 2, 'vcpus': 2}, 'ansible_loop_var': 'item'})
ok: [localhost] => (item={'changed': False, 'stdout': '192.168.123.170', 'stderr': '', 'rc': 0, 'cmd': "virsh domifaddr k8s-worker2 | grep ipv4 | awk '{print $4}' | cut -d '/' -f1", 'start': '2025-11-07 19:52:48.510001', 'end': '2025-11-07 19:52:48.524201', 'delta': '0:00:00.014200', 'msg': '', 'invocation': {'module_args': {'cmd': "virsh domifaddr k8s-worker2 | grep ipv4 | awk '{print $4}' | cut -d '/' -f1", '_uses_shell': True, 'expand_argument_vars': True, 'stdin_add_newline': True, 'strip_empty_ends': True, '_raw_params': None, 'argv': None, 'chdir': None, 'executable': None, 'creates': None, 'removes': None, 'stdin': None}}, 'stdout_lines': ['192.168.123.170'], 'stderr_lines': [], 'failed': False, 'attempts': 1, 'item': {'name': 'k8s-worker2', 'disk_gb': 20, 'mem_gb': 2, 'vcpus': 2}, 'ansible_loop_var': 'item'})

TASK [provision_k8s_vms : Wait for SSH to be available on all new VMs] *************************************************
ok: [localhost] => (item=192.168.123.168)
ok: [localhost] => (item=192.168.123.169)
ok: [localhost] => (item=192.168.123.170)

TASK [provision_k8s_vms : Run teardown tasks] **************************************************************************
skipping: [localhost]

PLAY [Configure Kubernetes on the new VMs] *****************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [192.168.123.169]
ok: [192.168.123.170]
ok: [192.168.123.168]

TASK [k8s_prereqs : Include OS-specific prerequisite tasks] ************************************************************
included: /home/your_user/repos/github.com/your_user74/ansible_kvm/roles/k8s_prereqs/tasks/setup-Debian.yml for 192.168.123.168, 192.168.123.169, 192.168.123.170

TASK [k8s_prereqs : Load OS-specific variables for common packages] ****************************************************
ok: [192.168.123.168]
ok: [192.168.123.169]
ok: [192.168.123.170]

TASK [k8s_prereqs : Install common packages] ***************************************************************************
ok: [192.168.123.170]
ok: [192.168.123.168]
ok: [192.168.123.169]

TASK [k8s_prereqs : Ensure required kernel modules are loaded] *********************************************************
changed: [192.168.123.168] => (item=br_netfilter)
changed: [192.168.123.169] => (item=br_netfilter)
changed: [192.168.123.170] => (item=br_netfilter)
changed: [192.168.123.170] => (item=overlay)
changed: [192.168.123.169] => (item=overlay)
changed: [192.168.123.168] => (item=overlay)

TASK [k8s_prereqs : Set required sysctl parameters for Kubernetes networking] ******************************************
changed: [192.168.123.168] => (item={'name': 'net.bridge.bridge-nf-call-iptables', 'value': '1'})
changed: [192.168.123.169] => (item={'name': 'net.bridge.bridge-nf-call-iptables', 'value': '1'})
changed: [192.168.123.170] => (item={'name': 'net.bridge.bridge-nf-call-iptables', 'value': '1'})
changed: [192.168.123.169] => (item={'name': 'net.ipv4.ip_forward', 'value': '1'})
changed: [192.168.123.168] => (item={'name': 'net.ipv4.ip_forward', 'value': '1'})
changed: [192.168.123.170] => (item={'name': 'net.ipv4.ip_forward', 'value': '1'})
changed: [192.168.123.169] => (item={'name': 'net.bridge.bridge-nf-call-ip6tables', 'value': '1'})
changed: [192.168.123.168] => (item={'name': 'net.bridge.bridge-nf-call-ip6tables', 'value': '1'})
changed: [192.168.123.170] => (item={'name': 'net.bridge.bridge-nf-call-ip6tables', 'value': '1'})

TASK [k8s_prereqs : Disable swap for the current session] **************************************************************
skipping: [192.168.123.168]
skipping: [192.168.123.169]
skipping: [192.168.123.170]

TASK [k8s_prereqs : Disable swap persistently in /etc/fstab] ***********************************************************
ok: [192.168.123.169]
ok: [192.168.123.168]
ok: [192.168.123.170]

TASK [containerd : Include OS-specific containerd setup] ***************************************************************
included: /home/your_user/repos/github.com/your_user74/ansible_kvm/roles/containerd/tasks/setup-Debian.yml for 192.168.123.168, 192.168.123.169, 192.168.123.170

TASK [containerd : Install containerd] *********************************************************************************
changed: [192.168.123.169]
changed: [192.168.123.168]
changed: [192.168.123.170]

TASK [containerd : Create containerd config directory] *****************************************************************
changed: [192.168.123.168]
changed: [192.168.123.169]
changed: [192.168.123.170]

TASK [containerd : Ensure containerd config file is present with default values] ***************************************
changed: [192.168.123.168]
changed: [192.168.123.169]
changed: [192.168.123.170]

TASK [containerd : Ensure SystemdCgroup is set to true] ****************************************************************
changed: [192.168.123.168]
changed: [192.168.123.169]
changed: [192.168.123.170]

TASK [containerd : Ensure containerd service is active and enabled] ****************************************************
ok: [192.168.123.168]
ok: [192.168.123.169]
ok: [192.168.123.170]

TASK [kube_master : Include OS-specific kube_master setup] *************************************************************
skipping: [192.168.123.169]
skipping: [192.168.123.170]
included: /home/your_user/repos/github.com/your_user74/ansible_kvm/roles/kube_master/tasks/setup-Debian.yml for 192.168.123.168

TASK [kube_master : Create directory for Kubernetes apt keyrings] ******************************************************
ok: [192.168.123.168]

TASK [kube_master : Add Kubernetes GPG key] ****************************************************************************
changed: [192.168.123.168]

TASK [kube_master : Add Kubernetes apt repository] *********************************************************************
changed: [192.168.123.168]

TASK [kube_master : Install kubeadm, kubelet, kubectl] *****************************************************************
changed: [192.168.123.168]

TASK [kube_master : Hold Kubernetes packages at their current version] *************************************************
changed: [192.168.123.168] => (item=kubeadm)
changed: [192.168.123.168] => (item=kubelet)
changed: [192.168.123.168] => (item=kubectl)

TASK [kube_master : Enable kubelet service] ****************************************************************************
ok: [192.168.123.168]

TASK [kube_master : Initialize Kubernetes cluster] *********************************************************************
changed: [192.168.123.168]

TASK [kube_master : Create .kube directory for ubuntu user] ************************************************************
changed: [192.168.123.168]

TASK [kube_master : Copy admin.conf to user's .kube directory] *********************************************************
changed: [192.168.123.168]

TASK [kube_master : Wait for the API server to be ready] ***************************************************************
FAILED - RETRYING: [192.168.123.168]: Wait for the API server to be ready (60 retries left).
FAILED - RETRYING: [192.168.123.168]: Wait for the API server to be ready (59 retries left).
FAILED - RETRYING: [192.168.123.168]: Wait for the API server to be ready (58 retries left).
FAILED - RETRYING: [192.168.123.168]: Wait for the API server to be ready (57 retries left).
FAILED - RETRYING: [192.168.123.168]: Wait for the API server to be ready (56 retries left).
FAILED - RETRYING: [192.168.123.168]: Wait for the API server to be ready (55 retries left).
FAILED - RETRYING: [192.168.123.168]: Wait for the API server to be ready (54 retries left).
ok: [192.168.123.168]

TASK [kube_master : Install Calico Pod Network Addon] ******************************************************************
changed: [192.168.123.168]

TASK [kube_master : Wait for the master node to be Ready] **************************************************************
FAILED - RETRYING: [192.168.123.168]: Wait for the master node to be Ready (60 retries left).
FAILED - RETRYING: [192.168.123.168]: Wait for the master node to be Ready (59 retries left).
FAILED - RETRYING: [192.168.123.168]: Wait for the master node to be Ready (58 retries left).
FAILED - RETRYING: [192.168.123.168]: Wait for the master node to be Ready (57 retries left).
FAILED - RETRYING: [192.168.123.168]: Wait for the master node to be Ready (56 retries left).
FAILED - RETRYING: [192.168.123.168]: Wait for the master node to be Ready (55 retries left).
FAILED - RETRYING: [192.168.123.168]: Wait for the master node to be Ready (54 retries left).
FAILED - RETRYING: [192.168.123.168]: Wait for the master node to be Ready (53 retries left).
changed: [192.168.123.168]

TASK [kube_master : Get kubeadm join command for workers] **************************************************************
changed: [192.168.123.168]

TASK [kube_master : Save join command for later use] *******************************************************************
ok: [192.168.123.168]

TASK [kube_worker : Include OS-specific kube_worker setup] *************************************************************
skipping: [192.168.123.168]
included: /home/your_user/repos/github.com/your_user74/ansible_kvm/roles/kube_worker/tasks/setup-Debian.yml for 192.168.123.169, 192.168.123.170

TASK [kube_worker : Create directory for Kubernetes apt keyrings] ******************************************************
ok: [192.168.123.169]
ok: [192.168.123.170]

TASK [kube_worker : Add Kubernetes GPG key] ****************************************************************************
changed: [192.168.123.169]
changed: [192.168.123.170]

TASK [kube_worker : Add Kubernetes apt repository] *********************************************************************
changed: [192.168.123.169]
changed: [192.168.123.170]

TASK [kube_worker : Install kubeadm, kubelet, kubectl] *****************************************************************
changed: [192.168.123.169]
changed: [192.168.123.170]

TASK [kube_worker : Hold Kubernetes packages at their current version] *************************************************
changed: [192.168.123.170] => (item=kubeadm)
changed: [192.168.123.169] => (item=kubeadm)
changed: [192.168.123.170] => (item=kubelet)
changed: [192.168.123.169] => (item=kubelet)
changed: [192.168.123.170] => (item=kubectl)
changed: [192.168.123.169] => (item=kubectl)

TASK [kube_worker : Enable kubelet service] ****************************************************************************
ok: [192.168.123.169]
ok: [192.168.123.170]

TASK [kube_worker : Join worker to the cluster] ************************************************************************
```
