# Kind Cluster Setup with Nginx Ingress and Argo CD

This repository provides a `Makefile` to quickly set up a local Kubernetes cluster using [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/) with [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/) and [Argo CD](https://argo-cd.readthedocs.io/).

## Prerequisites

Before you begin, ensure you have the following tools installed on your system:

* **Docker:** Kind requires Docker to run Kubernetes nodes as containers. Follow the installation instructions [here](https://docs.docker.com/get-docker/).
* **kubectl:** The Kubernetes command-line tool is essential for interacting with your cluster. Install it as described [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
* **Kind:** Kubernetes IN Docker. Install it following the [official quick start guide](https://kind.sigs.k8s.io/docs/user/quick-start/).
* **Helm:** A package manager for Kubernetes, used to install Argo CD. Installation instructions can be found [here](https://helm.sh/docs/intro/install/).
* **(Optional) kubens:** A handy tool to easily switch between Kubernetes namespaces. You can find the installation instructions [here](https://github.com/ahmetb/kubectx).
* **make:** A build automation tool. It's likely already installed on most Linux and macOS systems.

## Getting Started with Makefile

This repository simplifies the setup process using a `Makefile`. Follow these steps:

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/anhtranquang/lab-cluster
    cd lab-cluster
    ```
    *(Replace `https://github.com/anhtranquang/lab-cluster` and `<lab-cluster` with the actual repository URL and directory name)*

2.  **Configure Hostname (for local access):**
    Before creating the cluster, if you intend to access Argo CD via a specific hostname (as defined in `bootstrap-manifests/argocd-ingress.yaml`), you need to configure your local machine's `/etc/hosts` file (or the equivalent for your operating system). Add an entry mapping the desired hostname to `127.0.0.1`. For example, if your `argocd-ingress.yaml` uses `argocd.local`, add the following line to your `/etc/hosts` file:
    ```
    127.0.0.1 argocd.local
    ```
    This ensures that when you navigate to `http://argocd.local` in your browser, the request is routed to your local machine where the Ingress Controller will be running.

3.  **Create and Deploy the Cluster and Components:**
    Run the following command to create the Kind cluster and deploy Nginx Ingress Controller and Argo CD:
    ```bash
    make build deploy
    ```
    This single command will:
    * Create a Kind cluster named `lab` using the `cluster.yaml` configuration.
    * Deploy the Nginx Ingress Controller.
    * Install Argo CD using Helm.
    * Apply the Ingress resource for Argo CD.

4.  **Login to Argo CD:**
    After the `make deploy` command completes, you can retrieve the initial administrator password using the following command:
    ```bash
    make argocd-password
    ```
    This will execute the necessary `kubectl` command and print the decoded password.

    You can then access the Argo CD UI by navigating to the hostname you configured in your `/etc/hosts` file (e.g., `http://argocd.local`). The username is `admin` and the password is the one you retrieved.

## Makefile Targets

Here's a breakdown of the available `make` commands:

* **`make build`**: Creates the Kind cluster named `lab` using the `cluster.yaml` configuration.
* **`make deploy`**: Deploys the Nginx Ingress Controller and Argo CD to the created Kind cluster. This target depends on the `build` target, so it will create the cluster if it doesn't exist.
* **`make argocd-password`**: Retrieves and decodes the initial Argo CD administrator password.
* **`make clean`**: Deletes the Kind cluster named `lab`.

## Repository Contents

* `cluster.yaml`: Configuration file for creating the Kind cluster with a control plane and labeled worker nodes (including a dedicated ingress worker).
* `bootstrap-manifests/`: Directory containing Kubernetes manifests for bootstrapping the cluster.
    * `deploy-ingress-nginx.yaml`: Manifest to deploy the Nginx Ingress Controller.
    * `argocd-ingress.yaml`: Manifest to create an Ingress resource for Argo CD. **Make sure to check and adjust the `host` value in this file to match your `/etc/hosts` configuration.**
* `Makefile`: Automates the cluster creation and component deployment process.

## Next Steps

After successfully setting up your Kind cluster with Nginx Ingress and Argo CD, you can explore the following:

* **Deploy Applications with Argo CD:** Learn how to define and deploy applications using GitOps principles with Argo CD. Refer to the [Argo CD documentation](https://argo-cd.readthedocs.io/).
* **Configure Ingress Rules:** Define Ingress rules to expose your applications running within the cluster through the Nginx Ingress Controller. See the [Kubernetes Ingress documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/).
* **Explore Kind Configuration:** Customize your Kind cluster further by modifying the `cluster.yaml` file. Check the [Kind configuration documentation](https://kind.sigs.k8s.io/docs/config/).

## Cleanup

To delete the Kind cluster when you are finished:

```bash
make clean