# Ansible KVM Kubernetes Lab

This project is a collection of Ansible playbooks and roles designed for learning and experimenting ("noodling") with Ansible, KVM/QEMU, and Kubernetes. It provides a fully automated way to stand up and tear down Kubernetes clusters on a single, powerful Linux host.

The primary goal is to go from a bare-metal Linux machine to a multi-node Kubernetes cluster with a single command, while building the automation in a portable, reusable, and professional way.

## Core Features

This repository provides three distinct, self-contained workflows:

1.  **Multi-Node KVM Kubernetes Cluster:** The main feature. A single playbook (`k8s_cluster_kvm.yml`) provisions a 3-node (1 master, 2 worker) Kubernetes cluster inside KVM virtual machines. It handles everything from host preparation to VM creation to Kubernetes installation.
2.  **Single-Node Local Kubernetes Cluster:** A simpler setup that installs a complete, single-node Kubernetes cluster directly on the host operating system. This is useful for quick tests without the overhead of virtualization.
3.  **Single KVM Test VM:** A utility playbook for quickly creating a single, general-purpose Ubuntu VM for testing or development, based on the successful patterns discovered during this project.

## Prerequisites

Before running the playbooks, ensure your host machine is set up correctly.

1.  **Host OS:** A modern Linux distribution. This project has been heavily tested on an Arch-based system (CachyOS) but is designed to be portable to Debian/Ubuntu and Red Hat/Fedora hosts.
2.  **Hardware:** A machine with virtualization support (Intel VT-x or AMD-V) enabled in the BIOS. A multi-core CPU (8+ cores) and significant RAM (16GB+) are recommended.
3.  **Software:**
    *   Python 3 and `pip`.
    *   Ansible (`ansible-core`).
    *   An SSH key (e.g., `~/.ssh/id_ed25519.pub`). The path can be configured.
    *   Passwordless `sudo` configured for the user running the playbooks.
4.  **Ansible Requirements:** Install the necessary Python libraries and Ansible collections.
```bash
# Install Python dependencies for Ansible modules
pip install -r requirements.txt

# Install required Ansible collections
ansible-galaxy collection install community.general
```

## Usage

### Main Workflow: Multi-Node KVM Cluster

This is the primary workflow for creating the 3-node Kubernetes lab.

**To Create the Cluster:**
```bash
# This single command will prepare the host, create 3 VMs, and install Kubernetes.
ansible-playbook k8s_cluster_kvm.yml
```
When the playbook completes, it will have automatically copied the `admin.conf` file to `~/.kube/config` on your local host. You can immediately interact with your new cluster.

**To Verify the Cluster:**
```bash
kubectl get nodes -o wide
```

**To Destroy the Cluster:**
```bash
# This will power off and delete the VMs, disks, ISOs, and network.
ansible-playbook k8s_cluster_kvm_teardown.yml
```

### Utility Workflow: Single Test VM

This is useful for quickly spinning up a single, general-purpose VM.

**To Create the VM:**
```bash
ansible-playbook create_vm.yml
```

**To Destroy the VM:**
```bash
ansible-playbook create_vm_teardown.yml
```

### Legacy Workflow: Local Kubernetes Cluster

This installs Kubernetes directly on your host OS. It is managed via a convenient wrapper script.

**To Create the Local Cluster:**
```bash
./local_k8s_ctl.sh start
```

**To Destroy the Local Cluster:**
```bash
./local_k8s_ctl.sh stop
```

## Project Structure

This project is organized into top-level playbooks and a set of modular, reusable roles.

### Top-Level Files

*   `ansible.cfg`: Main configuration for Ansible. Sets the default inventory file and other parameters.
*   `requirements.txt`: Python library dependencies required by the Ansible modules used in this project.
*   `inventory.yml`: The default inventory, used by the KVM playbooks. It only defines `localhost` as the target for provisioning.
*   `inventory-local.yml`: A dedicated inventory for the local Kubernetes installation.
*   `k8s_cluster_kvm.yml`: The main entry point. A multi-play playbook that provisions a 3-node KVM cluster and then configures Kubernetes on it.
*   `k8s_cluster_kvm_teardown.yml`: The corresponding teardown playbook for the multi-node cluster.
*   `create_vm.yml`: A utility playbook that creates a single, general-purpose KVM virtual machine.
*   `create_vm_teardown.yml`: The corresponding teardown playbook for the single test VM.
*   `local_k8s_setup_start.yml`: The legacy playbook for installing Kubernetes directly on the host OS.
*   `local_k8s_stop.yml`: The corresponding teardown playbook for the local Kubernetes installation.
*   `local_k8s_ctl.sh`: A user-friendly wrapper script for managing the local Kubernetes installation.

### Roles

#### `roles/kvm_host`
*   **Responsibility:** Prepares the host machine to be a KVM hypervisor.
*   `tasks/main.yml`: Installs virtualization packages, configures `libvirt` to be compatible with the host firewall (`ufw`), and ensures the `libvirtd` service is running.
*   `vars/`: Contains OS-specific variable files (`Archlinux.yml`, `Debian.yml`, `RedHat.yml`) that define the correct package names for virtualization components.
*   `handlers/main.yml`: Contains the handler to restart the `libvirtd` service if its configuration is changed.

#### `roles/provision_k8s_vms`
*   **Responsibility:** Creates and destroys the KVM virtual machines for the Kubernetes cluster.
*   `defaults/main.yml`: Defines all user-configurable variables for the cluster, such as the list of VMs, SSH key path, network details, and cloud image URL.
*   `tasks/main.yml`: A dispatcher that calls `present.yml` or `absent.yml` based on the `state` variable.
*   `tasks/present.yml`: Contains the logic to create the virtual network, download the OS image, create disks, generate cloud-init ISOs, and define/start the VMs. It finishes by creating an in-memory inventory for subsequent plays.
*   `tasks/absent.yml`: Contains the logic to cleanly destroy all VMs, disks, ISOs, and the virtual network.
*   `templates/`: Contains the Jinja2 templates for the `libvirt` network XML (`k8s-net.xml.j2`), the VM domain XML (`vm_domain.xml.j2`), and the cloud-init files (`user-data.j2`, `meta-data.j2`).

#### `roles/create_vm`
*   **Responsibility:** A self-contained utility role for creating a single test VM. It serves as a proven reference for the patterns used in the main `provision_k8s_vms` role.
*   `meta/main.yml`: Defines a dependency on the `kvm_host` role to ensure the host is ready.
*   `defaults/main.yml`: Defines the variables for the single test VM.
*   `tasks/present.yml` & `tasks/absent.yml`: Contain the logic for creating and destroying the single VM and its associated network.

#### `roles/k8s_prereqs`
*   **Responsibility:** Prepares an operating system to be a Kubernetes node.
*   `tasks/main.yml`: A dispatcher that calls an OS-specific task file.
*   `tasks/setup-*.yml`: Contains the logic to disable swap, load required kernel modules (`br_netfilter`, `overlay`), and set necessary `sysctl` parameters.
*   `vars/`: Contains OS-specific variables for package names and swap services.

#### `roles/containerd`
*   **Responsibility:** Installs and configures the `containerd` container runtime.
*   `tasks/main.yml`: A dispatcher that calls an OS-specific task file.
*   `tasks/setup-*.yml`: Contains the idempotent logic to install `containerd`, generate its default configuration, and ensure `SystemdCgroup` is enabled.
*   `handlers/main.yml`: Contains the handler to restart `containerd` if its configuration changes.

#### `roles/kube_master`
*   **Responsibility:** Initializes the Kubernetes control plane on the master node.
*   `tasks/main.yml`: A dispatcher that calls an OS-specific task file.
*   `tasks/setup-*.yml`: Contains the logic to install `kubeadm`, run `kubeadm init`, install the Calico CNI, and generate a join token for the worker nodes. It includes robust "wait" tasks to handle race conditions during startup.

#### `roles/kube_worker`
*   **Responsibility:** Joins worker nodes to an existing Kubernetes cluster.
*   `tasks/main.yml`: A dispatcher that calls an OS-specific task file.
*   `tasks/setup-*.yml`: Contains the logic to install `kubeadm` and run the `kubeadm join` command provided by the master node.
