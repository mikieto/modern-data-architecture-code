# Use an official Python runtime as a parent image
# Using a specific version like 3.10 on Debian "Bookworm" provides stability
FROM python:3.10-slim-bookworm

# Set environment variables to prevent interactive prompts during package installations
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /work

# Install system dependencies including Git, curl, unzip, jq, and ca-certificates
# Also install gnupg for adding package repositories securely and vim/less for convenience
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    unzip \
    jq \
    ca-certificates \
    gnupg \
    vim \
    less && \
    # Clean up apt caches to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Terraform (using HashiCorp official instructions - modified for bookworm and newer gpg handling)
# Fetches the HashiCorp GPG key, adds the repository, and installs Terraform
RUN apt-get update && apt-get install -y gpg wget && \
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    # Verify the key fingerprint (optional but recommended for security)
    # gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com bookworm main" > /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && \
    apt-get install -y terraform && \
    # Clean up apt caches and keyring file to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Install AWS CLI v2 (using official AWS instructions)
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    # Clean up downloaded files
    rm -rf awscliv2.zip ./aws

# Install dbt-core using pip
# We specify a version range for stability. Specific adapters (e.g., dbt-snowflake)
# can be installed in later chapters or by modifying this Dockerfile if needed.
RUN pip install --no-cache-dir dbt-core~=1.8.0 # Example: Use dbt Core version 1.8.x

# (Optional) Install other necessary Python packages if needed globally
# Example: RUN pip install --no-cache-dir pandas scikit-learn

# Verify installations (optional but good practice for build checks)
RUN echo "Verifying tool installations..." && \
    git --version && \
    terraform --version && \
    aws --version && \
    dbt --version && \
    python --version && \
    pip --version && \
    echo "Tool verification complete."

# Reset DEBIAN_FRONTEND environment variable
ENV DEBIAN_FRONTEND=

# Default command to keep the container running (useful with docker compose)
# Allows users to 'exec' into the container for interactive use.
CMD ["sleep", "infinity"]