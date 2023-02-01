# installer

### Prerequisites

- MacOS or a supported Linux (RedHat, CentOS, or Rocky for now)
- curl
- docker

### Installation

To execute a singlestep install of the latest released version of DeltaFi in a self contained KinD (Kubernetes in Docker) cluster:

```bash
bash -c "$(curl -fsSL https://gitlab.com/systolic/deltafi/installer/-/raw/main/kind-install.sh)"
```

or...if you like to see what you are running first

```bash
curl -fsSL https://gitlab.com/systolic/deltafi/installer/-/raw/main/kind-install.sh > kind-install.sh
chmod +x kind-install.sh
./kind-install.sh
```
