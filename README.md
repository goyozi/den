# den

Den allows you to package your entire development environment into a docker image. It runs the specified docker image
in a fresh X session and pushes the updated container to registry once the session is over.

## Installation

**To work properly den requires Xorg and docker to be installed.**

```
git clone https://github.com/terrifish/den.git
cd den/
chmod +x den.sh
./den.sh install
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

## Configuration

Currently the only supported option is passing extra docker parameters. You can do this by setting the DOCKER_OPTS
environment variable e.g.

```
export DOCKER_OPTS="--device /dev/snd"
```

**Please note that you must not change the container name via `DOCKER_OPTS`. Otherwise den will not work properly.

## Uninstallation

```
den remove
rm -r {{ den sources directory }}
```
