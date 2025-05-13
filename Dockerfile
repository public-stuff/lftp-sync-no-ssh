FROM alpine:latest

# Install required packages
RUN apk update && apk --no-cache add lftp bash

# Set environment variables
ARG USER
ARG PASSWORD
ARG HOST
ARG REMOTE_DIR
ENV USER=$USER
ENV PASSWORD=$PASSWORD
ENV HOST=$HOST
ENV REMOTE_DIR=$REMOTE_DIR
ENV SYNC_INTERVAL=${SYNC_INTERVAL:-3600}

# Create downloads directory
RUN mkdir -p /downloads

# Create entrypoint script with extreme verbosity enabled
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Turn on bash debugging' >> /entrypoint.sh && \
    echo 'set -x' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Function to create lftp script on-the-fly' >> /entrypoint.sh && \
    echo 'run_sync() {' >> /entrypoint.sh && \
    echo '  echo "================================================================"' >> /entrypoint.sh && \
    echo '  echo "Starting lftp sync at $(date)"' >> /entrypoint.sh && \
    echo '  echo "================================================================"' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '  # Create a temporary lftp script with debugging commands' >> /entrypoint.sh && \
    echo '  cat > /tmp/lftp_script << EOL' >> /entrypoint.sh && \
    echo 'debug 9' >> /entrypoint.sh && \
    echo 'set cmd:verbose true' >> /entrypoint.sh && \
    echo 'set cmd:trace true' >> /entrypoint.sh && \
    echo 'set xfer:log true' >> /entrypoint.sh && \
    echo 'set net:max-retries 2' >> /entrypoint.sh && \
    echo 'set net:timeout 10' >> /entrypoint.sh && \
    echo 'set ssl:verify-certificate no' >> /entrypoint.sh && \
    echo 'set ftp:ssl-force true' >> /entrypoint.sh && \
    echo 'open -u "$USER","$PASSWORD" "$HOST"' >> /entrypoint.sh && \
    echo 'pwd' >> /entrypoint.sh && \
    echo 'ls -la' >> /entrypoint.sh && \
    echo 'cd $REMOTE_DIR' >> /entrypoint.sh && \
    echo 'ls -la' >> /entrypoint.sh && \
    echo '# First try a simple get to test output visibility' >> /entrypoint.sh && \
    echo 'get -o /dev/null *.* &' >> /entrypoint.sh && \
    echo 'wait all' >> /entrypoint.sh && \
    echo '# Now do the actual mget' >> /entrypoint.sh && \
    echo 'mget -v -c -P 5 -O /downloads *.*' >> /entrypoint.sh && \
    echo '# And finally the mirror command' >> /entrypoint.sh && \
    echo 'mirror --verbose --use-pget-n=5 --parallel=2 . /downloads' >> /entrypoint.sh && \
    echo 'bye' >> /entrypoint.sh && \
    echo 'EOL' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '  # Run lftp with explicit script' >> /entrypoint.sh && \
    echo '  lftp -f /tmp/lftp_script' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '  echo "================================================================"' >> /entrypoint.sh && \
    echo '  echo "lftp sync finished at $(date)"' >> /entrypoint.sh && \
    echo '  echo "================================================================"' >> /entrypoint.sh && \
    echo '}' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Run in continuous loop' >> /entrypoint.sh && \
    echo 'while true; do' >> /entrypoint.sh && \
    echo '  run_sync' >> /entrypoint.sh && \
    echo '  echo "Waiting $SYNC_INTERVAL seconds until next sync..."' >> /entrypoint.sh && \
    echo '  sleep $SYNC_INTERVAL' >> /entrypoint.sh && \
    echo 'done' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]