# Seedbox Sync

## Description

This Dockerfile and Docker Compose configuration sets up a service, `seedbox-sync`, to synchronize files between a remote server and a local directory. It's primarily designed for use with a seedbox, automating the download of completed files. It only uses lftp and does not require ssh or ssh access to the remote server.

## Usage

### Prerequisites

-   Docker and Docker Compose installed on your system.
-   Access to a remote server (seedbox) with the necessary files.

### Configuration

1.  **Clone the repository (Optional):** If you have this `docker-compose.yml` in a git repository, clone it to your local machine.
2.  **Create a `.env` file:** In the same directory as the `docker-compose.yml` file, create a file named `.env`.  This file will store your environment variables.
3.  **Edit the `.env` file:** Add the following lines to your `.env` file, replacing the values with your actual configuration:

    ```
    USER=<your_remote_username>
    PASSWORD=<your_remote_password>
    HOST=<your_remote_server_address_or_hostname>
    REMOTE_DIR=<path_to_the_remote_directory_to_sync>
    LOCAL_DIR=<path_to_your_local_download_directory> # Optional, defaults to ./downloads
    SYNC_INTERVAL=<sync_interval_in_seconds> # Optional, defaults to 3600 (1 hour)
    ```

    * **`USER`**:  The username for your account on the remote server.
    * **`PASSWORD`**: The password for your account on the remote server.
    * **`HOST`**:  The hostname or IP address of your remote server.
    * **`REMOTE_DIR`**:  The directory on the remote server that you want to synchronize (e.g., the directory where your seedbox stores completed downloads).
    * **`LOCAL_DIR`**:  (Optional) The directory on your local machine where you want the files to be downloaded. If not specified, it defaults to `./downloads`.
    * **`SYNC_INTERVAL`**: (Optional) The interval, in seconds, at which the synchronization should occur.  Defaults to 3600 seconds (1 hour) if not provided.

    **Important Security Note:** Storing passwords in a `.env` file is generally NOT recommended for production environments due to security concerns.  For more secure alternatives, consider using Docker secrets or environment variables provided through a more secure mechanism.

4.  **Run Docker Compose:** Open a terminal in the directory containing the `docker-compose.yml` file and the `.env` file, and execute the following command:

    ```bash
    docker-compose up -d
    ```

    This will start the `seedbox-sync` container in detached mode (running in the background).

### Stopping the Container

To stop the container, execute the following command in the same directory:

```bash
docker-compose down
Details from docker-compose.ymlHere's a breakdown of the docker-compose.yml file:image: seedbox-sync:latest:  Specifies the Docker image to use for the service.  It assumes you have a locally built image named seedbox-sync:latest.  You might need to build this image yourself using a Dockerfile.container_name: seedbox-sync:  Sets the name of the Docker container.hostname: seedbox-sync: Sets the hostname of the container.user: root:  Runs the container as the root user.  This might be necessary for certain file operations, but it's generally recommended to use a non-root user for security reasons if possible.restart: unless-stopped:  Configures Docker to restart the container automatically unless it is explicitly stopped.environment:  Defines the environment variables that are passed to the container:USER:  The remote username (taken from the .env file).PASSWORD: The remote password (taken from the .env file).HOST:  The remote host address (taken from the .env file).REMOTE_DIR:  The remote directory to sync (taken from the .env file).SYNC_INTERVAL: The sync interval in seconds (taken from the .env file or defaults to 3600).volumes:  Mounts a volume to the container:${LOCAL_DIR:-./downloads}:/downloads:  Mounts the local directory (specified by the LOCAL_DIR environment variable) to the /downloads directory inside the container.  If the LOCAL_DIR variable is not set, it defaults to ./downloads.  This allows the container to write downloaded files to your local file system.Image Build (Important!)This docker-compose.yml assumes that you have already built the seedbox-sync:latest Docker image. You will need a Dockerfile to define how this image is built.  A basic Dockerfile might look something like this (but you'll need to adapt it to your specific synchronization needs, likely using rsync, lftp, or a similar tool):FROM ubuntu:latest

# Install necessary tools (e.g., rsync)
RUN apt-get update && \
    apt-get install -y rsync openssh-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set up a working directory
WORKDIR /app

# Copy your synchronization script (if you have one)
# COPY sync_script.sh /app/sync_script.sh
# RUN chmod +x /app/sync_script.sh

# Define the entrypoint (what command to run when the container starts)
# ENTRYPOINT ["/app/sync_script.sh"]  # Or, for example:
CMD ["/usr/bin/rsync", "-avz", "$REMOTE_DIR/", "/downloads/"]
Key points about the Dockerfile:Base Image: It starts from a base Ubuntu image.  You can choose a different base image if needed.Install Tools: It installs rsync and openssh-client, which are commonly used for file synchronization.  You might need different tools.Working Directory: It sets /app as the working directory inside the container.Copy Script (Optional): If you have a custom script to handle the synchronization, you would copy it into the container.Entrypoint/CMD: This is crucial.  It defines the command that runs when the container starts.  In this example, I've added a sample CMD that uses rsync.  You will almost certainly need to modify this to fit your exact synchronization needs. You might use a different command, or you might use an ENTRYPOINT script for more complex logic.Build the image:To build this image, save the Dockerfile in the same directory as your docker-compose.yml and .env files, and then run this command:docker build -t seedbox-sync:latest .
Be sure to replace the example CMD in the Dockerfile with the actual command or script you need to perform the synchronization.
