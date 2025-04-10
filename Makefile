KIND_CLUSTER_NAME := lab
CONFIG_FILE := cluster.yaml
BOOTSTRAP_MANIFESTS := bootstrap-manifests
INGRESS_MANIFEST := $(BOOTSTRAP_MANIFESTS)/deploy-ingress-nginx.yaml
ARGOCD_INGRESS_MANIFEST := $(BOOTSTRAP_MANIFESTS)/argocd-ingress.yaml
ARGOCD_NAMESPACE := argocd

.PHONY: build deploy clean argocd-password

build: kind-cluster

kind-cluster:
	@echo "Creating Kind cluster '${KIND_CLUSTER_NAME}'..."
	kind create cluster --config "$(CONFIG_FILE)" --name "$(KIND_CLUSTER_NAME)"
	@echo "Kind cluster '${KIND_CLUSTER_NAME}' created."

deploy: build deploy-ingress deploy-argocd

deploy-ingress:
	@echo "Applying Nginx Ingress Controller..."
	kubectl apply -f "$(INGRESS_MANIFEST)"
	@echo "Waiting for Nginx Ingress Controller pod to be running..."
	kubectl wait --namespace ingress-nginx --for=condition=Ready pod --selector=app.kubernetes.io/component=controller --timeout=5m
	@echo "Nginx Ingress Controller deployed."

deploy-argocd:
	@echo "Adding Argo CD Helm repository..."
	helm repo add argo https://argoproj.github.io/argo-helm
	@echo "Updating Helm repositories..."
	helm repo update
	@echo "Installing Argo CD..."
	helm install argocd argo/argo-cd --namespace "$(ARGOCD_NAMESPACE)" --create-namespace --wait
	@echo "Applying Argo CD Ingress..."
	kubectl apply -f "$(ARGOCD_INGRESS_MANIFEST)" -n "$(ARGOCD_NAMESPACE)"
	@echo "Argo CD deployed. You can retrieve the initial admin password with:"
	@echo "make argocd-password"

argocd-password:
	@echo "Retrieving Argo CD initial admin password..."
	kubectl -n "$(ARGOCD_NAMESPACE)" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

clean: clean-kind
	@echo "Cleanup complete."

clean-kind:
	@echo "Deleting Kind cluster '${KIND_CLUSTER_NAME}'..."
	kind delete cluster --name "$(KIND_CLUSTER_NAME)"
	@echo "Kind cluster '${KIND_CLUSTER_NAME}' deleted."