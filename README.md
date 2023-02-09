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

### Creating a skeleton plugin
A new plugin can be initialized using the `deltafi plugin-init` command. This will prompt for the information necessary to create the plugin. Alternatively, you can initialize a new plugin by passing a configuration file to the command: `deltafi plugin-init -f plugin-config.json`.

Below are the steps to generate the [example-project](https://gitlab.com/deltafi/example-plugin). This must be run in the parent directory of the `deltafi` directory that was created by the installer.
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

### Building a simple flow in your plugin
Flows are versioned and packaged as part of your plugin source code. In a Java project they are located in `src/main/resources/flows`, in a Python project they are located in `src/flows/`.
Flows can reference both actions local to your plugin and any other actions that are running on your DeltaFi instance.
The next sections walk through building the flows for the example project.

#### Update the Ingress Flow
In this ingress flow we do not require any transform actions, we will process the incoming data as is in the load action.

1. Open the `sample-ingress.json` in an editor
1. Delete the transformActions array, in this simple flow we do not need to preprocess data prior to the load action
1. Update the loadAction type to `org.deltafi.example.actions.JsonLoadAction` which is the full classname of the LoadAction generated earlier (the type is used to route the DeltaFile to the correct Action class that will act upon the DeltaFile).
1. Remove the parameters object, this load action does not require any parameters

#### Update the Enrich Flow
This flow does not require any domain validation or enrichment, the `sample-enrich.json` file can be removed

#### Update the Egress Flow
The egress flow will contain the FormatAction which formats the Json domain object as Yaml.

1. Open the `sample-egress.json` in an editor
1. Delete the valiateActions array, in this flow we do not need to validate the output of the format action
1. Update the formatAction type to `org.deltafi.example.actions.YamlFormatAction` which is the full classname of the FormatAction generated earlier

#### Plugin Variables
For actions that require parameters there is an option to use variable substitution in the flow plan.  The `variables.json` holds all the variables that can be set in the plugin as well as any default values for those variables. To reference a variable in a flow surround the value with ${}. In the egress flow there is an example of this, the ${egressUrl} is a variable which can then be updated at runtime.

### Testing your plugin
After the action logic is implemented and the flows are updated, the plugin can be built and installed with the following steps.
```bash
./gradlew clean build dockerPushLocal`
deltafi install-plugin org.deltafi.example:example-plugin:latest -i localhost:5000/
```

Once the plugin installation is complete you can enable the flows on the [flow config page](https://local.deltafi.org/config/flows)
To run data through the flow you can go to the [upload page](https://local.deltafi.org/deltafile/upload/), choose your ingress flow and upload a file.
There will be link to the DeltaFile after the file is uploaded

### Adding an additional flow to your plugin
New flows can be created under the `flows` directory. Any code changes or flow changes will require the docker image to be rebuilt. If the plugin is already running in your local cluster you can delete the pod to pick up the changes.