# AMD ROCm for Slackware

Here are the scripts to build AMD ROCm on Slackware 15 x86_64 current tree.

>[!NOTE]
> I'm using wget with option content-disposition=on into /etc/wgetrc config file.
> In order the shell scripts to work you must also use this option.

First you need to activate the environment with

```bash
   source rocm-environment.sh
```

With these scripts I build ROCm from version 6.1 to 7.0.1. Just change
version number in rocm-environment.sh file. You could found some precompiled
binary packages from me version: 7.0.1 on my repository [HERE](https://www.ixip.net/rocm/)

1. Few packages will need to installed and all of them is required. Check file:

cpackage-requirements

and you could download compiled binary or build scripts from repo written above.

2. Create your virtual environment and install the python packages

```bash
    python3 -m venv virtualenv
    source virtualenv/bin/activate
    pip3 install -r python-requirements
```

Follow the build order.

>[!NOTE]
>
> The compilation process usual take 3 days if you will compile composable kernel package
> if not, one day and half if no errors.


## Not Build

The few packages from ROCm does not compiled for some reasons.

These packages from "ROCm core packages" are:
```
ROCmValidationSuite requires manual intervention
```

### AMDGPU PRO libraries

The package 100.amdprolibs.sh is separete package contain AMDGPU PRO libraries.
This package does not need to compile / install full ROCm.
I read somewhere AMD shutting down AMDGPU PRO project, last version is 6.4

Have fun and cheers,
Condor
