# den

Den allows you to package your entire development environment into a docker image. It runs the specified docker image
in a fresh X session and pushes the updated container to registry once the session is over.

## Installation

**To work properly den requires Xorg and docker to be installed.**

```
git clone https://github.com/terrifish/den.git
cd den/
chmod +x den.sh
sudo ./den.sh install
```

## Basic Usage

Creating a new environment:

```
den init {{ base image name }} {{ environment image name }}
```

Starting an existing environment:

```
den start {{ environment image name }}
```

If your user is not in the docker group, you might need to add `sudo` before all the commands.

## Configuration

All configuration is done by environment variables, so that you can run your development environments
by specifying just the name, without any extra parameters.

To pass extra options to the `docker run` command, you can set the `DOCKER_OPTS` environment variable e.g.

```
export DOCKER_OPTS="--device /dev/snd"
```

**Please note that you must not change the container name via `DOCKER_OPTS`. Otherwise den will not work properly.**

To change the arguments passed to the `xhost` command before running the Xorg server, you can set the `XHOST_OPTS` environment variable e.g.

```
export XHOST_OPTS="+" # allows everyone to connect
```

To change the arguments passed to the `startx` command after the initialization script name, you can set the `STARTX_OPTS` variable e.g.

```
export STARTX_OPTS="-- :0 -listen tcp" # starts X in a Window without keyhook
```

The X initialization script starts your docker image passing along the `DISPLAY` environment variable.
For Linux computers, this is just passing the value already set by X, while for Windows it uses your local IP.
If you want to change the way `DISPLAY` is passed to the docker image, you can simply set `DISPLAY` yourself:

```
export DISPLAY=":1"
```

On Windows, by default, `XHOST_OPTS` and `DISPLAY` is run with your computers local IP,
which den attempts to guess using your `ipconfig`. If the detection doesn't work properly
or you want to change it for some reason, you can set the `LOCAL_IP` variable e.g.

```
export LOCAL_IP="X.X.X.X"
```

## Uninstallation

```
sudo den remove
rm -r {{ den sources directory }}
```
