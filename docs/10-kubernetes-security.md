# 10 — Kubernetes Security Notes

Kubernetes' own security checklist emphasizes least-privilege RBAC, image scanning/signing, secrets protection, and avoiding unnecessary service-account token exposure.
Reference: https://kubernetes.io/docs/concepts/security/security-checklist/

## 1. Security boundaries to keep in your head

```text
cluster
 ├─ control plane
 ├─ node
 │   ├─ kubelet
 │   └─ container runtime
 └─ namespace
     ├─ workload identity
     ├─ RBAC
     ├─ network policy
     └─ resource policy
```

A namespace is not a complete security boundary by itself.

## 2. RBAC: ask “what can this identity do?”

Inspect a role:

```bash
kubectl get role,rolebinding -A
kubectl describe role <role> -n <namespace>
kubectl describe rolebinding <binding> -n <namespace>
```

Check a user's effective permission:

```bash
kubectl auth can-i get pods -n app
kubectl auth can-i create deployments -n app
```

The difference between `get`, `list`, `watch`, `create`, `update`, `patch`, and `delete` matters. Kubernetes specifically warns that some write permissions can become escalation paths, such as permissions that allow changing roles or workloads.
Reference: https://kubernetes.io/docs/concepts/security/application-security-checklist/

## 3. Service accounts

Inspect:

```bash
kubectl get serviceaccounts -A
kubectl get pod <pod> -o yaml
```

If a workload does not need the Kubernetes API, disable automatic token mounting:

```yaml
automountServiceAccountToken: false
```

Kubernetes recommends avoiding service-account tokens in pods that do not need them and favors bound tokens for modern clusters.
Reference: https://kubernetes.io/docs/concepts/security/security-checklist/

## 4. Secrets

Do not use ConfigMaps for confidential values.

```bash
kubectl get configmap -n app
kubectl get secret -n app
```

Remember: Kubernetes Secret objects are not automatically equivalent to “encrypted everywhere.” Configure encryption at rest for the API datastore and consider an external secret-management integration for higher-assurance environments.

Also watch the difference between “base64 encoded” and “encrypted.” Base64 is an encoding, not a security control.

## 5. Pod security baseline

A practical pod should have constraints such as:

```yaml
securityContext:
  runAsNonRoot: true
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop: ["ALL"]
```

Some workloads require exceptions. The security goal is to make the exception explicit rather than leaving every pod unrestricted.

## 6. NetworkPolicy

A default-deny model is easier to reason about than “allow everything, then patch holes.”

Example teaching manifest:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: app
spec:
  podSelector: {}
  policyTypes:
    - Ingress
```

Then add only the flows the application needs.

## 7. Image security

Before deployment:

```bash
kubectl get pods -A -o wide
kubectl describe pod <pod> -n <namespace>
```

Inspect the actual image references:

```bash
kubectl get deploy <deployment> -n <namespace> -o jsonpath='{.spec.template.spec.containers[*].image}'; echo
```

For high-assurance deployments, use image signing/verification and admission controls where your platform supports them. Kubernetes recommends scanning images and validating signatures before deployment.
Reference: https://kubernetes.io/docs/concepts/security/application-security-checklist/

## 8. Resource limits are security too

Unlimited resource consumption can become an availability problem.

Example:

```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

Set values based on observed application behavior. Arbitrary tiny limits can cause false failures.

## 9. Kubernetes practical: prove RBAC least privilege

Create a role that permits reading pods but not deleting them:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: app
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
```

Then validate:

```bash
kubectl auth can-i get pods --as=system:serviceaccount:app:reader -n app
kubectl auth can-i delete pods --as=system:serviceaccount:app:reader -n app
```

The important output is not the YAML; it is the proof that the identity can perform exactly the operations it needs.
