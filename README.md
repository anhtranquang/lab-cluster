# Kind Cluster Setup with Nginx Ingress and Argo CD

This repository provides a `Makefile` to quickly set up a local Kubernetes cluster using [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/) with [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/) and [Argo CD](https://argo-cd.readthedocs.io/).

## Prerequisites

Ensure you have the following tools installed:

- **Docker**: Required for running Kind clusters.
- **kubectl**: Kubernetes command-line tool.
- **Helm**: Kubernetes package manager.
- **Kind**: Tool for running local Kubernetes clusters.

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

2.  **Set Up Git Credentials:**
    Ensure you have the following information ready:
    - Git repository URL (e.g., `https://github.com/your-repo.git`)
    - Git username
    - Git API key

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
  * `argocd-ingress.yaml`: Manifest to create an Ingress resource for Argo CD. **The `host` value in this file is set to `argocd.localhost`, which resolves automatically to `127.0.0.1`.**
  * `applicationset.yaml`: Defines an ArgoCD ApplicationSet for managing multiple applications.
* `tools/`: Directory containing Helm values and configurations for additional tools.
  * `kestra/values.yaml`: Helm values file for deploying Kestra.
* `Makefile`: Automates the cluster creation, tool deployment, and cleanup processes.
* `README.md`: Documentation for setting up and managing the lab cluster.

## Next Steps

After successfully setting up your Kind cluster with Nginx Ingress and Argo CD, you can explore the following:

* **Deploy Applications with Argo CD:** Learn how to define and deploy applications using GitOps principles with Argo CD. Refer to the [Argo CD documentation](https://argo-cd.readthedocs.io/).
* **Configure Ingress Rules:** Define Ingress rules to expose your applications running within the cluster through the Nginx Ingress Controller. See the [Kubernetes Ingress documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/).
* **Explore Kind Configuration:** Customize your Kind cluster further by modifying the `cluster.yaml` file. Check the [Kind configuration documentation](https://kind.sigs.k8s.io/docs/config/).

## Cleanup

To delete the Kind cluster when you are finished:

```bash
make clean