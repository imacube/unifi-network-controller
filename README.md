# UniFi Network Controller in docker with systemd startup

The UniFi Network Controller software requires a specific version range of MongoDB. This was created to allow the
controller to run on a Linux distribution that did not have packages for the supported MongoDB version.

__Warning:__ this uses `--privileged` & `--network=host`, review the `Makefile`.

The `Makefile` sets the timezone to "America/Pacific"; to use an alternate timezone it must be manually changed
in the `Makefile`.

The script, `docker-entrypoint.bash`, handles the starting and stopping of MongoDB and UniFi Network Controller
services within the docker container along with some basic administrative tasks to accommodate this docker container
running with volumes.

The controller installation process used in the `Dockerfile` was derived from:
[UniFi - How to Install and Update via APT on Debian or Ubuntu](https://help.ui.com/hc/en-us/articles/220066768-UniFi-How-to-Install-and-Update-via-APT-on-Debian-or-Ubuntu)

_Note:_ this docker container uses volumes to provide persistent storage of the MongoDB database and the UniFi Network
Controller. You must create the directories either by running `make volume` or manually create them.

## Building and Installing

The build process is handled by the `Makefile`.

1. Create the volumes used by the docker container.

   If you have ZFS it is recommended that you create a ZFS filesystem for these volumes to be stored in so snapshots
   can be created just for this service.

   _Note:_ see [Directories used by UniFi Network Controller and MongoDB](#directories-used-by-unifi-network-controller-and-mongodb)

   ```shell
   make volume
  ```

2. Build the image.

   ```shell
   make build
   ```

3. Run `make shell` if you want to startup the container and verify the contents.

   _Note:_ this starts MongoDB and the UniFi Network Controller with the docker volumes attached.

   This can be a useful tool to verify the volumes are correctly configured and the filesystem permissions are correct.

4. Create the Docker container.

   ```shell
   make create
   ```

5. If desired you can start the container.

   _Note:_ this starts MongoDB and the UniFi Network Controller.

   Remember to stop the container before having Systemd start it.

   ```shell
   make start
   make stop
   ```

6. Install the Systemd unit.

   ```shell
   sudo cp unifi-network-controller.service /etc/systemd/system/unifi-network-controller.service
   sudo systemctl daemon-reload
   sudo systemctl enable unifi-network-controller.service
   ```

7. Start the service.

   ```shell
   sudo systemctl start unifi-network-controller.service
   ```

8. Verify it's running.

  ```shell
  docker ps
  ```

## Upgrading

If you are using ZFS it is highly recommended that a snapshot be taken of the filesystem containing the persistent
volumes used by the docker container.

1. Build the new image.

   ```shell
   make build
   ```

2. Stop the current service.

   ```shell
   sudo systemctl stop unifi-network-controller.service
   ```

3. Remove the old image.

   ```shell
   make rm
   ```

4. Create the new container.

   ```shell
   make container
   ```

5. Update the Systemd unit (may not be necessary).

   ```shell
   sudo cp unifi-network-controller.service /etc/systemd/system/unifi-network-controller.service
   sudo systemctl daemon-reload
   ```

6. Start the service.

   ```shell
   sudo systemctl start unifi-network-controller.service
   ```

7. Verify it's running.

   ```shell
   docker ps
   ```

## Directories used by UniFi Network Controller and MongoDB

The following directories are used by UniFi Network Controller and MongoDB. The docker container uses volume
directives to retain the state outside of docker.

- `/var/lib/unifi/`
- `/var/log/unifi/`
- `/var/lib/mongodb/`
- `/var/log/mongodb/`

### To automatically create these directories

```shell
make volume
```

They will be created under the parent directory: `/opt/unifi-network-controller`. If you are using ZFS it is strongly
recommended that this path be its own ZFS filesystem so that snapshots may be taken before upgrading the UniFi Network
Controller software without worrying about other programs activity.

## UniFi Network Controller software

The software can be downloaded from here:
[Ubiquiti - Downloads](https://www.ui.com/download/unifi)

See the "SOFTWARE" sub-section of the webpage. This docker container installs
the Debian package via apt, but it can be useful to pull the package and explore it. See: [Extracting a .deb file](#extracting-a-.deb-file)

## Extracting a .deb file

Notes on how to extract a `.deb` file with out installing it.

_Warning:_ the contents are extracted to the current directory, not into a sub-directory. This can be messy.

```shell
mkdir unifi_sysvinit_all
cp unifi_sysvinit_all.deb unifi_sysvinit_all
cd unifi_sysvinit_all
ar x unifi_sysvinit_all.deb
```
