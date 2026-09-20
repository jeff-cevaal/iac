helm install traefik traefik/traefik

https://cert-manager.io/docs/tutorials/getting-started-aks-letsencrypt/

helm install \
  cert-manager oci://quay.io/jetstack/charts/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.21.2 \
  --set crds.enabled=true