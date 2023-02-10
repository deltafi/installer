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

The UI can be accessed at `https://local.deltafi.org`.

### Exploring DeltaFi

- Passthrough data, etc.

## Getting started with a DeltaFi plugin

### Installing the development environment

To execute a singlestep install of the latest released version of DeltaFi in a self contained KinD (Kubernetes in Docker) cluster:

```bash
curl -fsSL https://gitlab.com/deltafi/installer/-/raw/main/kind-install.sh > kind-install.sh
chmod +x kind-install.sh
./kind-install.sh --dev
```

If you have previously done a demo install, you can simply execute the development bootstrap as follows:

```bash
deltafi/bootstrap-dev.sh
```

The UI can be accessed at `http://local.deltafi.org` and the Grafana metrics dashboard can be accessed at `https://metrics.local.deltafi.org/dashboards`.  You should visit those links in your browser to verify that the installation process is complete.  Note: You will need to accept security warnings in your browser for missing certificates.

> We should fix this so we can just use http:// links for everything.

You can execute the following commands to see status from the command line:

```bash
# See status of the DeltaFi subsystems running in the local Kubernetes cluster
kubectl get pods
```

```bash
# See the DeltaFi system check status
deltafi status
```

```bash
# See the current versions of subsystems and plugins running in your DeltaFi instance
deltafi versions
```

### Creating a skeleton plugin
A new plugin can be initialized using the `deltafi plugin-init` command. This will prompt for the information necessary to create the plugin. Alternatively, you can initialize a new plugin by passing a configuration file to the command: `deltafi plugin-init -f plugin-config.json`.

Below are the steps to generate the [example-project](https://gitlab.com/deltafi/example-plugin). This must be run in the parent directory of the `deltafi` directory that was created by the installer (your location after running the singlestep install process).

```bash
cat <<EOF > plugin-config.json
{
  "artifactId": "example-plugin",
  "groupId": "org.deltafi.example",
  "description": "A plugin that takes in json, normalizes the keys and outputs yaml",
  "pluginLanguage": "JAVA",
  "actions": [
    {
      "className": "JsonLoadAction",
      "description": "Maps incoming json keys to all lowercase and loads the result in a domain under example-json",
      "actionType": "LOAD"
    },
    {
      "className": "YamlFormatAction",
      "description": "Acts on any DeltaFile with a domain of example-json, converts the json to yaml",
      "actionType": "FORMAT"
    }
  ]
}
EOF
deltafi plugin-init -f plugin-config.json
```

If the plugin directory was created with root permissions, you may need to take the following step to make the plugin source editable

```bash
sudo chmod -R a+rwX example-plugin
```

> This is ugly.  We need to find a workaround to make the perms right from the get-go.  The most likely way is to wrap the deltafi plugin-init command in the cluster command and just for the KinD CLI, we generate the zip file, then unzip it with the outer caller, so permissions are correct, then remove the zip from within the cluster shell.

### Building a simple flow in your plugin
Flows are versioned and packaged as part of your plugin source code. In a Java project they are located in `src/main/resources/flows`, in a Python project they are located in `src/flows/`.
Flows can reference both actions local to your plugin and any other actions that are running on your DeltaFi instance.
The next sections walk through building the flows for the example project.

#### Update the Ingress Flow
For this example, we do not require any transform actions, we will process the incoming data as-is in the load action.

We will remove the sample flows and create a new set of flows for our example plugin:

```bash
rm -f example-plugin/src/main/resources/flows/sample*.json

# Create an ingress flow
cat <<EOF > example-plugin/src/main/resources/flows/example-ingress.json
{
  "name": "example-ingress",
  "type": "INGRESS",
  "description": "Ingress flows require a load action and can optional contain one or more transform actions",
  "loadAction": {
    "name": "ExampleLoadAction",
    "type": "org.deltafi.example.actions.JsonLoadAction"
  }
}
EOF

# Create an egress flow
cat <<EOF > example-plugin/src/main/resources/flows/example-ingress.json
{
  "name": "example-egress",
  "type": "EGRESS",
  "description": "Egress flows require a format action and an egress action and optionally can provide one or more validate actions",
  "includeIngressFlows": [
    "example-ingress"
  ],
  "formatAction": {
    "name": "ExampleFormatAction",
    "type": "org.deltafi.example.actions.YamlFormatAction",
    "requiresDomains": [
      "example-json"
    ]
  },
  "egressAction": {
    "name": "ExampleEgressAction",
    "type": "org.deltafi.core.action.RestPostEgressAction",
    "parameters": {
      "metadataKey": "deltafiMetadata",
      "url": "${egressUrl}"
    }
  }
}
EOF

# Set configuration variables
cat <<EOF > example-plugin/src/main/resources/flows/example-ingress.json
[
  {
    "name": "egressUrl",
    "description": "The URL to post the DeltaFile to",
    "dataType": "STRING",
    "required": true,
    "defaultValue": "http://deltafi-egress-sink-service"
  }
]
EOF
```

### Adding some logic to load and format actions

#### ---TBD---

### Building and Installing your plugin

DeltaFi has a development CLI command called `cluster` which we will use for this example.

```bash
# Install the DeltaFi passthrough plugin
deltafi plugin-install org.deltafi.passthrough:deltafi-passthrough:$(deltafi version)

# Register the example plugin with cluster tool
cluster plugin add-local example-plugin org.deltafi.example

# Build and install the example-plugin
cluster plugin build install
```

If you make changes to your plugin, you may re-run `cluster plugin build install` to update the plugin with your changes.

If you want to compile and execute tests for your plugin, you can do so from the `example-plugin` directory:
```bash
./gradlew build test
```

### Testing your plugin

Once the plugin installation is complete you can enable the flows on the [flow config page](https://local.deltafi.org/config/flows)
To run data through the flow you can go to the [upload page](https://local.deltafi.org/deltafile/upload/), choose your ingress flow and upload a file.
There will be link to the DeltaFile after the file is uploaded

### Adding an additional flow to your plugin
New flows can be created under the `flows` directory. Any code changes or flow changes will require the docker image to be rebuilt. If the plugin is already running in your local cluster you can delete the pod to pick up the changes.
