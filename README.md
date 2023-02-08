# Getting started with DeltaFi

Instructions follow to set up a demo DeltaFi cluster with a simple passthrough plugin installed, or to set up a DeltaFi development environment with a walkthrough to deploy your first plugin.

### Prerequisites

In order to start up a demo DeltaFi or to set up a DeltaFi development environment, you will need a MacOS system or a supported Linux system (currently tested on CentOS 8 and Rocky 9).  Preferably 8GB RAM, 200GB free disk space, and 4 CPU cores, but your mileage will vary according to your system specs.  Note that the installation process requires the installation of 3rd party software on the target system (like KinD, OpenJDK 17, etc.) as well as starting up a containerized Kubernetes cluster.  This process is highly automated.

The target system should also have the following installed:
- Docker or Docker Desktop (make sure your user account can access docker without sudo)
- curl
- A window manager for Linux systems (KDE, XFCE, etc.)
- A web browser (Google Chrome is preferred)

For development, it is recommended that an IDE like IntelliJ or Visual Studio Code is installed for writing plugin code.  The IDE will be presumed and not covered in this tutorial.

## Getting started with a demo DeltaFi cluster


### Installation Instructions

To execute a singlestep install of the latest released version of DeltaFi in a self contained KinD (Kubernetes in Docker) cluster:

```bash
curl -fsSL https://gitlab.com/deltafi/installer/-/raw/main/kind-install.sh > kind-install.sh
chmod +x kind-install.sh
./kind-install.sh
```

After the installation is complete run `deltafi set-admin-password <password>` to set the admin password. The UI can be accessed at  `https://local.deltafi.org` using the `admin` user account.

### Exploring DeltaFi

- Passthrough data, etc.

## Getting started with a DeltaFi plugin

### Installing the development environment

### Creating a skeleton plugin

### Building a simple flow in your plugin

### Testing your plugin

### Adding an additional flow to your plugin
