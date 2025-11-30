# Base Jenkins LTS
FROM jenkins/jenkins:lts

# Switch to root
USER root

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies: Docker, Git, curl, unzip, Java
RUN apt-get update && \
    apt-get install -y \
        docker.io \
        git \
        curl \
        unzip \
        openjdk-21-jdk-headless \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" && \
    unzip /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/aws /tmp/awscliv2.zip

# Add Jenkins user to docker group
RUN groupadd -f docker && usermod -aG docker jenkins

# Switch back to Jenkins user
USER jenkins

# Expose Jenkins ports
EXPOSE 8080 50000

CMD ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]
