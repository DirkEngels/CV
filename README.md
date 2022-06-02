# Curriculum Vitae
This repository contains the Curriculum Vitae of Dirk Engels.
It is deployed and can be viewed at: [cv.dirkengels.com](https://cv.dirkengels.com).

## Quick Start
Make use of the Makefile to get started.
This will assume you have docker installed.
It will download a docker image to run to static project files on.

## Usage
Even my C.V. contains a Makefile. Run *make* without any arguments to see the
following options:

#### Run locally
```bash
# make start
```

## Deploy
This only applies when docker swarm is enabled.
Otherwise use the start/stop/status commands to control the container.
```bash
# make deploy
```
