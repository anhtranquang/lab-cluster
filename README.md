# Kind Cluster Setup with Nginx Ingress and Argo CD

This repository provides scripts and manifests to quickly set up a local Kubernetes cluster using [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/) with [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/) and [Argo CD](https://argo-cd.readthedocs.io/).

## Prerequisites

Before you begin, ensure you have the following tools installed on your system:

* **Docker:** Kind requires Docker to run Kubernetes nodes as containers. Follow the installation instructions [here](https://docs.docker.com/get-docker/).
* **kubectl:** The Kubernetes command-line tool is essential for interacting with your cluster. Install it as described [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
* **Kind:** Kubernetes IN Docker. Install it following the [official quick start guide](https://kind.sigs.k8s.io/docs/user/quick-start/).
* **Helm:** A package manager for Kubernetes, used to install Argo CD. Installation instructions can be found [here](https://helm.sh/docs/intro/install/).
* **(Optional) kubens:** A handy tool to easily switch between Kubernetes namespaces. You can find the installation instructions [here](https://github.com/ahmetb/kubectx).

## Getting Started

Follow these steps to create your Kind cluster and install the necessary components:

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/anhtranquang/lab-cluster
    cd lab-cluster
    ```
    *(Replace `https://github.com/anhtranquang/lab-cluster` and `<lab-cluster` with the actual repository URL and directory name)*

2.  **Create the Kind Cluster:**
    ```bash
    kind create cluster --config cluster.yaml --name lab
    ```
    This command uses the `cluster.yaml` configuration file in this repository to define your Kind cluster named `lab`.

    **`cluster.yaml` Description:**
    This file configures a Kind cluster with:
    * A single control plane node.
    * Multiple worker nodes, including a dedicated worker labeled for `ingress` with host port mappings for HTTP (80) and HTTPS (443), and a taint to dedicate it for Ingress Controller pods.
    * Additional worker nodes labeled for `infra` and `app` to demonstrate node affinity for different types of workloads.

3.  **Install Nginx Ingress Controller:**
    This step deploys the Nginx Ingress Controller to the `ingress-nginx` namespace on your cluster.
    ```bash
    kubectl apply -f bootstrap-manifests/deploy-ingress-nginx.yaml
    ```
    Verify that the Nginx Ingress Controller pod is running:
    ```bash
    kubectl get pod -n ingress-nginx
    ```
    You should see at least one pod in a `Running` state.

4.  **Install Argo CD:**
    We will use Helm to install Argo CD into its own namespace.
    ```bash
    helm repo add argo [https://argoproj.github.io/argo-helm](https://argoproj.github.io/argo-helm)
    helm repo update
    helm install argocd charts/argo-cd --namespace argocd --create-namespace --wait
    ```
    * `helm repo add argo https://argoproj.github.io/argo-helm`: Adds the Argo CD Helm chart repository.
    * `helm repo update`: Updates the list of available charts from the added repositories.
    * `helm install argocd charts/argo-cd --namespace argocd --create-namespace --wait`: Installs the Argo CD chart into the `argocd` namespace, creating the namespace if it doesn't exist, and waits for the installation to complete.

5.  **Apply Ingress for Argo CD:**
    This step configures an Ingress resource to expose the Argo CD UI.
    ```bash
    kubectl apply -f bootstrap-manifests/argocd-ingress.yaml -n argocd
    ```
    *Note: Ensure your `bootstrap-manifests/argocd-ingress.yaml` is configured correctly for your environment, especially the `host` value.*

6.  **Login to Argo CD:**
    To access the Argo CD UI, you'll need the initial administrator password. Retrieve it using the following command:
    ```bash
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    ```
    This command fetches the secret, extracts the password (which is base64 encoded), and decodes it.

    You can then access the Argo CD UI through the hostname specified in your `bootstrap-manifests/argocd-ingress.yaml` file (e.g., `argocd.example.com` if that's what you configured). The username is `admin` and the password is the one you retrieved.

## Repository Contents

* `cluster.yaml`: (Optional) Configuration file for creating the Kind cluster.
* `bootstrap-manifests/`: Directory containing Kubernetes manifests for bootstrapping the cluster.
    * `deploy-ingress-nginx.yaml`: Manifest to deploy the Nginx Ingress Controller.
    * `argocd-ingress.yaml`: Manifest to create an Ingress resource for Argo CD.

## Next Steps

After successfully setting up your Kind cluster with Nginx Ingress and Argo CD, you can explore the following:

* **Deploy Applications with Argo CD:** Learn how to define and deploy applications using GitOps principles with Argo CD. Refer to the [Argo CD documentation](https://argo-cd.readthedocs.io/).
* **Configure Ingress Rules:** Define Ingress rules to expose your applications running within the cluster through the Nginx Ingress Controller. See the [Kubernetes Ingress documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/).
* **Explore Kind Configuration:** Customize your Kind cluster by modifying the `cluster.yaml` file. Check the [Kind configuration documentation](https://kind.sigs.k8s.io/docs/config/).

## Cleanup

To delete the Kind cluster when you are finished:

```bash
kind delete cluster --name lab