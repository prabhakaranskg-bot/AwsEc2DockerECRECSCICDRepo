# Base Jenkins LTS image
FROM jenkins/jenkins:lts

# Switch to root to install dependencies
USER root

# Install required packages: git, curl, unzip, docker.io
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    docker.io \
 && rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" \
 && unzip /tmp/awscliv2.zip -d /tmp \
 && /tmp/aws/install \
 && rm -rf /tmp/aws /tmp/awscliv2.zip

# Switch back to Jenkins user
USER jenkins

# Expose Jenkins ports
EXPOSE 8080 50000

# Default command
CMD ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]
