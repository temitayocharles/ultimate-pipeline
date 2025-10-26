# Step 5: Kubernetes Initialization

**Duration:** 20 minutes

**Goal:** Initialize Kubernetes cluster on master node and join worker nodes


---


## What You Will Accomplish

By the end of this step:

* Kubernetes master node will be initialized
* Calico network plugin will be installed
* Worker nodes will join the cluster
* You will have a functioning 3-node Kubernetes cluster


---


## Task 1: Initialize Kubernetes Master

The master node controls the entire Kubernetes cluster.


### Instructions

**1.1** SSH to the Jenkins/K8s master node:

```bash
cd ~/Documents/PROJECTS/ec2-k8s
ssh -i k8s-pipeline-key.pem ubuntu@<JENKINS_MASTER_PUBLIC_IP>
```


Replace `<JENKINS_MASTER_PUBLIC_IP>` with the IP from your terraform outputs.


**1.2** Once connected, verify you're on the master:

```bash
hostname
```


**Expected output:**
```
jenkins-k8s-master
```


**1.3** Run the Kubernetes initialization script:

```bash
/home/ubuntu/init-k8s-master.sh
```


**This script will:**
* Initialize kubeadm with pod network CIDR 10.244.0.0/16
* Configure kubectl for the ubuntu user
* Install Calico network plugin
* Generate a join command for worker nodes


**Expected output (this takes 2-3 minutes):**
```
[init] Using Kubernetes version: v1.31.x
[preflight] Running pre-flight checks
[kubelet-start] Writing kubelet environment file
[certs] Generating certificates and keys
...
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, run:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
...

Then you can join any number of worker nodes by running the following on each:

kubeadm join 172.31.21.117:6443 --token abcdef.0123456789abcdef \
        --discovery-token-ca-cert-hash sha256:1234567890abcdef...
```


**1.4** The script automatically configures kubectl. Verify it worked:

```bash
kubectl get nodes
```


**Expected output:**
```
NAME                 STATUS     ROLES           AGE   VERSION
jenkins-k8s-master   NotReady   control-plane   30s   v1.28.1
```


**Note:** Status shows "NotReady" initially because Calico is still installing. This is normal.


**1.5** Wait for Calico to install (approximately 1 minute):

```bash
watch kubectl get nodes
```


**You will see the status change from NotReady to Ready:**
```
NAME                 STATUS   ROLES           AGE   VERSION
jenkins-k8s-master   Ready    control-plane   2m    v1.28.1
```


**Press Ctrl+C to exit the watch command.**


### Verification

**Master is ready when:**

```
[ ] kubectl get nodes shows master in Ready state
[ ] No error messages during initialization
[ ] .kube/config file exists in home directory
```


**Verify kubectl configuration:**

```bash
ls -la ~/.kube/config
```


**Should show:**
```
-rw------- 1 ubuntu ubuntu 5639 Oct 25 10:30 /home/ubuntu/.kube/config
```


---


## Task 2: Get Worker Join Command

Save the command needed to join worker nodes to the cluster.


### Instructions

**2.1** Generate a new join command (valid for 24 hours):

```bash
kubeadm token create --print-join-command
```


**Expected output:**
```
kubeadm join 172.31.21.117:6443 --token abc123.xyz789def456 --discovery-token-ca-cert-hash sha256:1a2b3c4d5e6f7g8h9i0j...
```


**2.2** Copy this ENTIRE command to your notes.


**IMPORTANT:** You will need this exact command in the next task. Copy it carefully.


### Verification

**The join command should:**
* Start with `kubeadm join`
* Include the master's private IP address
* Include a token (looks like: abc123.xyz789def456)
* Include a discovery hash (starts with sha256:)


---


## Task 3: Join Worker Node 1

Connect the first worker node to the cluster.


### Instructions

**3.1** Open a NEW terminal window (keep master SSH session open).


**3.2** SSH to Worker 1:

```bash
cd ~/Documents/PROJECTS/ec2-k8s
ssh -i k8s-pipeline-key.pem ubuntu@<WORKER1_PUBLIC_IP>
```


Replace `<WORKER1_PUBLIC_IP>` with the IP from terraform outputs.


**3.3** Verify hostname:

```bash
hostname
```


**Expected output:**
```
k8s-worker-1
```


**3.4** Run the join command (paste the ENTIRE command from Task 2):

```bash
sudo kubeadm join 172.31.21.117:6443 --token abc123.xyz789def456 --discovery-token-ca-cert-hash sha256:1a2b3c4d5e6f7g8h9i0j...
```


**Replace the example above with YOUR actual join command!**


**Expected output:**
```
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```


**3.5** The message "This node has joined the cluster" confirms success.


### Verification

**Switch back to the master terminal and verify:**

```bash
kubectl get nodes
```


**Expected output:**
```
NAME                 STATUS   ROLES           AGE     VERSION
jenkins-k8s-master   Ready    control-plane   5m      v1.28.1
k8s-worker-1         Ready    <none>          30s     v1.28.1
```


**Worker 1 should show Ready status within 30-60 seconds.**


---


## Task 4: Join Worker Node 2

Add the second worker node to the cluster.


### Instructions

**4.1** Open another NEW terminal window.


**4.2** SSH to Worker 2:

```bash
cd ~/Documents/PROJECTS/ec2-k8s
ssh -i k8s-pipeline-key.pem ubuntu@<WORKER2_PUBLIC_IP>
```


**4.3** Verify hostname:

```bash
hostname
```


**Expected output:**
```
k8s-worker-2
```


**4.4** Run the same join command from Task 2:

```bash
sudo kubeadm join 172.31.21.117:6443 --token abc123.xyz789def456 --discovery-token-ca-cert-hash sha256:1a2b3c4d5e6f7g8h9i0j...
```


**Expected output:** Same as Worker 1 - should end with "This node has joined the cluster"


### Verification

**Switch to master terminal and verify:**

```bash
kubectl get nodes
```


**Expected output:**
```
NAME                 STATUS   ROLES           AGE     VERSION
jenkins-k8s-master   Ready    control-plane   7m      v1.28.1
k8s-worker-1         Ready    <none>          2m      v1.28.1
k8s-worker-2         Ready    <none>          30s     v1.28.1
```


**All 3 nodes should show Ready status.**


---


## Task 5: Verify Cluster Health

Ensure all Kubernetes system components are running correctly.


### Instructions

**All commands run on the MASTER node.**


**5.1** Check all pods in kube-system namespace:

```bash
kubectl get pods -n kube-system
```


**Expected output:**
```
NAME                                         READY   STATUS    RESTARTS   AGE
calico-kube-controllers-xxxxxxxxxx-xxxxx     1/1     Running   0          5m
calico-node-xxxxx                            1/1     Running   0          5m
calico-node-yyyyy                            1/1     Running   0          2m
calico-node-zzzzz                            1/1     Running   0          1m
coredns-xxxxxxxxxx-xxxxx                     1/1     Running   0          5m
coredns-xxxxxxxxxx-yyyyy                     1/1     Running   0          5m
etcd-jenkins-k8s-master                      1/1     Running   0          5m
kube-apiserver-jenkins-k8s-master            1/1     Running   0          5m
kube-controller-manager-jenkins-k8s-master   1/1     Running   0          5m
kube-proxy-xxxxx                             1/1     Running   0          5m
kube-proxy-yyyyy                             1/1     Running   0          2m
kube-proxy-zzzzz                             1/1     Running   0          1m
kube-scheduler-jenkins-k8s-master            1/1     Running   0          5m
```


**All pods should show:**
* READY: 1/1
* STATUS: Running
* RESTARTS: 0 (or low number)


**5.2** Check node details:

```bash
kubectl get nodes -o wide
```


**Expected output:**
```
NAME                 STATUS   ROLES           AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
jenkins-k8s-master   Ready    control-plane   10m   v1.28.1   172.31.21.117   <none>        Ubuntu 24.04 LTS     6.8.0-1014-aws      containerd://1.7.x
k8s-worker-1         Ready    <none>          5m    v1.28.1   172.31.22.233   <none>        Ubuntu 24.04 LTS     6.8.0-1014-aws      containerd://1.7.x
k8s-worker-2         Ready    <none>          3m    v1.28.1   172.31.25.3     <none>        Ubuntu 24.04 LTS     6.8.0-1014-aws      containerd://1.7.x
```


**5.3** Verify cluster info:

```bash
kubectl cluster-info
```


**Expected output:**
```
Kubernetes control plane is running at https://172.31.21.117:6443
CoreDNS is running at https://172.31.21.117:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```


**5.4** Check component status:

```bash
kubectl get componentstatuses
```


**Expected output:**
```
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS    MESSAGE   ERROR
controller-manager   Healthy   ok
scheduler            Healthy   ok
etcd-0               Healthy   ok
```


The warning is normal for Kubernetes 1.28. All components should show "Healthy".


### Verification

**Cluster is healthy when:**

```
[ ] All 3 nodes show Ready status
[ ] All kube-system pods are Running
[ ] CoreDNS pods are running (2 replicas)
[ ] Calico pods are running (1 per node = 3 total)
[ ] Component status shows all Healthy
```


---


## Task 6: Create Application Namespace

Create a dedicated namespace for application deployments.


### Instructions

**6.1** Create namespace called "webapps":

```bash
kubectl create namespace webapps
```


**Expected output:**
```
namespace/webapps created
```


**6.2** Verify namespace creation:

```bash
kubectl get namespaces
```


**Expected output:**
```
NAME              STATUS   AGE
default           Active   15m
kube-node-lease   Active   15m
kube-public       Active   15m
kube-system       Active   15m
webapps           Active   10s
```


**6.3** Set webapps as default namespace for convenience:

```bash
kubectl config set-context --current --namespace=webapps
```


**Expected output:**
```
Context "kubernetes-admin@kubernetes" modified.
```


**6.4** Verify current namespace:

```bash
kubectl config view --minify | grep namespace:
```


**Expected output:**
```
    namespace: webapps
```


### Verification

**Namespace is ready when:**
* `kubectl get ns` shows webapps namespace
* Current context uses webapps namespace


---


## Task 7: Test Cluster with Sample Deployment

Deploy a test pod to verify cluster functionality.


### Instructions

**7.1** Create a test nginx deployment:

```bash
kubectl create deployment nginx-test --image=nginx:latest
```


**Expected output:**
```
deployment.apps/nginx-test created
```


**7.2** Wait for pod to start:

```bash
kubectl get pods
```


**Expected output:**
```
NAME                          READY   STATUS    RESTARTS   AGE
nginx-test-xxxxxxxxxx-xxxxx   1/1     Running   0          30s
```


**7.3** Check which node the pod is running on:

```bash
kubectl get pods -o wide
```


**Expected output:**
```
NAME                          READY   STATUS    RESTARTS   AGE   IP            NODE           
nginx-test-xxxxxxxxxx-xxxxx   1/1     Running   0          1m    10.244.1.2    k8s-worker-1
```


**Note:** Pod should be on one of the worker nodes (not the master).


**7.4** Delete the test deployment:

```bash
kubectl delete deployment nginx-test
```


**Expected output:**
```
deployment.apps "nginx-test" deleted
```


### Verification

**Test successful if:**
* Pod reached Running status
* Pod was scheduled on a worker node (not master)
* Pod could be deleted without errors


---


## Important Information to Record

**Add to your notes:**

```
=== Kubernetes Cluster ===
Master Node IP (Private): 172.31.21.117
Worker 1 IP (Private): 172.31.22.233
Worker 2 IP (Private): 172.31.25.3

Cluster API Server: https://172.31.21.117:6443

Application Namespace: webapps

Kubernetes Version: v1.28.1
Network Plugin: Calico
Pod Network CIDR: 10.244.0.0/16
```


---


## Troubleshooting

**Problem:** Master node stuck in NotReady state

**Solution:**
```bash
# Check Calico installation
kubectl get pods -n kube-system | grep calico

# If Calico pods are pending or failing, reinstall:
kubectl apply -f https://docs.projectcalico.org/v3.20/manifests/calico.yaml
```


**Problem:** Worker join fails with "connection refused"

**Solution:**
1. Verify master's private IP in join command is correct
2. Check security groups allow port 6443
3. Ensure cloud-init completed on master before joining workers


**Problem:** Token expired error when joining worker

**Solution:**
```bash
# On master, generate new token:
kubeadm token create --print-join-command

# Use the new command on worker
```


**Problem:** Pods stuck in Pending state

**Solution:**
```bash
# Check pod events
kubectl describe pod <pod-name>

# Check if nodes are ready
kubectl get nodes

# Check for resource constraints
kubectl top nodes
```


**Problem:** DNS not working in cluster

**Solution:**
```bash
# Verify CoreDNS pods are running
kubectl get pods -n kube-system | grep coredns

# Restart CoreDNS if needed
kubectl rollout restart deployment coredns -n kube-system
```


---


## Checklist: Kubernetes Initialization Complete

Verify before proceeding to Step 6:

```
[ ] Master node initialized successfully
[ ] Master node shows Ready status
[ ] Calico network plugin installed
[ ] Worker 1 joined cluster and shows Ready
[ ] Worker 2 joined cluster and shows Ready
[ ] All kube-system pods are Running
[ ] webapps namespace created
[ ] Test nginx pod deployed and ran successfully
[ ] kubectl commands work from master
[ ] All 3 nodes visible in kubectl get nodes
```


---


## Next Steps

Proceed to **Step 6: Jenkins Configuration** (`06-jenkins-setup.md`)

You will configure Jenkins with all required plugins, tools, and credentials.


**Note:** You can now close the SSH sessions to worker nodes. Keep the master session open for reference.


---


**Completion Time:** If all checks passed, you spent approximately 20 minutes.


**Your Kubernetes cluster is now fully operational!**
