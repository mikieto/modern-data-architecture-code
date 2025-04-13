# Modern Data Architecture Hands-on Code Repository

Welcome! This repository contains the companion code for the book "Building Modern Data Architectures". It provides hands-on exercises to help you build and operate a modern data platform step-by-step using Docker and AWS.

This README provides essential instructions for setting up your local environment to run the exercises smoothly.

**⚠️ IMPORTANT NOTE ON AWS COSTS & CLEANUP ⚠️**

The hands-on exercises in this book **will create real resources in your AWS account that incur costs.** It is **absolutely crucial** that you **destroy** these resources using `terraform destroy` (as instructed at the end of each relevant chapter) when you are finished with the exercises or taking a break for an extended period.

**Failure to clean up resources WILL result in ongoing charges to your AWS bill.** Please proceed with caution and manage your resources responsibly. Your use of cloud resources is at your own risk.

## Repository Structure

The code is organized by chapter:

* `Dockerfile`: Defines the tools and environment for our workspace container.
* `docker-compose.yml`: Configures how to build and run the workspace container, including volume mounts and environment variables.
* `.env.example`: Template for providing AWS credentials via environment variables. **<- You need to copy this to .env**
* `chapter04/`: Getting Started with Foundational Infrastructure (S3, IAM) with Terraform
* `chapter05/`: Building Core Data Pipelines (Kafka, dbt, Airflow)
* `chapter06/`: Implementing Data Governance & Compliance
* `chapter07/`: Integrating MLOps and AI for Data Leverage
* `chapter08/`: Applying DevOps for Data Engineering (CI/CD)
* `chapter09/`: Strategies for Cloud Migration & Coexistence
* `chapter10/`: Optimizing & Evolving Data Platforms (Scaling, Adoption)
* (Other directories might contain shared utilities or configurations)

Each `chapterXX/` directory contains chapter-specific code and potentially its own `README.md` for detailed steps.

## Prerequisites

Before you begin, please ensure you have the following available on your host machine:

* **Git:** To clone this repository.
    * **macOS/Linux:** Often pre-installed or easily installable via package manager.
    * **Windows (using WSL2):** Install via the package manager for your Linux distribution (e.g., `sudo apt update && sudo apt install git`).
    * **Verify:** Run `git --version` in your terminal.

* **Docker:** We **strongly recommend** using Docker for a consistent environment.
    * **macOS:** Install [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/).
    * **Windows:** Install [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/) (**WSL2 backend highly recommended**). Ensure WSL2 is enabled.
    * **Linux:** Install [Docker Engine](https://docs.docker.com/engine/install/).
    * **Verify:** Run `docker --version` in your terminal. Ensure the Docker daemon/service is running.
    * **License Note:** Please review Docker Desktop's licensing terms ([Docker Pricing](https://www.docker.com/pricing/)).

* **AWS Account:** An active AWS account with sufficient permissions to create resources (S3, IAM, etc.). Administrator access is simplest.
* **AWS Credentials:** You need access to your AWS Access Key ID and Secret Access Key (either long-term or, **preferably, short-term/temporary credentials**).

## Getting Started: Setting up Your Environment

Follow these steps **once** to set up your environment before starting the first hands-on chapter (Chapter 4).

**1. Clone the Repository:**

Open your terminal (use the WSL2 terminal if on Windows) and clone this repository:

```bash
git clone https://github.com/mikieto/modern-data-architecture-code.git
cd modern-data-architecture-code
```
All subsequent setup commands are run from the **root directory** of this repository unless otherwise specified.

**2. Configure AWS Credentials via `.env` File (IMPORTANT!)**

The tools inside the Docker container need your AWS credentials. **This is a critical step.** Use a `.env` file to provide these credentials as environment variables.

* **How it works:** Create a `.env` file (ignored by Git) from the `.env.example` template, fill it with your AWS credentials and region, and Docker Compose automatically loads these into the container as environment variables. AWS tools will use them automatically.

* **Steps:**
    1.  **Create `.env` file:** In the **root directory**, copy `.env.example` to `.env`:
        ```bash
        cp .env.example .env
        ```
    2.  **Edit `.env` file:** Open `.env` with a text editor.
    3.  **Fill in AWS Credentials (Mandatory!):** **This is crucial.** Provide valid AWS credentials by uncommenting **either** Option A **or** Option B in your `.env` file and pasting your values. Follow the comments in the file.
        * **Option A (Highly Recommended - Temporary Credentials):** Obtain temporary credentials (Key ID, Secret Key, Session Token) via IAM Identity Center, STS AssumeRole, etc. Uncomment the 3 lines for Option A and paste your values.
        * **Option B (Long-term IAM User Keys - Use with Caution):** Create keys for your IAM user (NEVER root) in the AWS Console (IAM > Users > Your User > Security credentials > Create access key). Select "CLI" or "Local code" as the use case. **Copy the Secret Key immediately (shown only once!).** Apply least privilege. Uncomment the 2 lines for Option B in `.env`, paste keys, ensure Session Token line is commented out.
        **You must complete either Option A or Option B.** We strongly recommend Option A.
    4.  **Set AWS Default Region:** Uncomment and set `AWS_DEFAULT_REGION` in `.env`. We recommend `us-east-1` for compatibility (see comments in `.env.example`).
    5.  **Save `.env`.**
    6.  **IMPORTANT: Never commit `.env`!** Ensure it's in `.gitignore`.
    7.  `docker-compose.yml` uses `env_file: .env`.

**3. Verify Docker is Running and Integrated (IMPORTANT!)**

Before building the image, ensure Docker is properly running and configured:

* **Start Docker:** Make sure **Docker Desktop** (on macOS/Windows) or the **Docker daemon/service** (on Linux) is **running**. You might need to launch the application manually.

* **(Windows WSL2 Users ONLY) Check WSL Integration:** If using Docker Desktop with WSL2, open Docker Desktop **Settings > Resources > WSL Integration**, and ensure the integration is **enabled** for your default WSL distribution (or the one you intend to use). If you just enabled it, restarting WSL might be necessary (`wsl --shutdown` in PowerShell/CMD, then reopen WSL terminal).

* **Verify Docker Command:** Open your terminal (or WSL2 terminal) and run `docker ps`. If it runs without errors (even if it shows an empty list), Docker is ready. If you get a "command not found" or connection error, troubleshoot your Docker installation/startup or WSL Integration.

**4. Build the Docker Image:**

Now that Docker is running correctly, from the **root directory** of the repository, build the Docker image:

```bash
docker compose build workspace
```
*(Note: `workspace` is the service name in `docker-compose.yml`. This might take a few minutes the first time.)*

**5. Start the Workspace Container:**

Start the `workspace` container in the background:

```bash
docker compose up -d workspace
```
Check status with `docker compose ps`. It should show the `mda_workspace` container as `running`.

**6. Access the Container's Shell:**

Connect to the running `workspace` container's shell. This is where you will run **most** hands-on commands:

```bash
docker compose exec workspace bash
```
You should see a prompt like `root@<container_id>:/work#`. The repo code is at `/work`.

**7. Verify Setup Inside Container:**

Inside the container's shell, verify tools and AWS access:

```bash
terraform --version && aws --version && aws sts get-caller-identity
```
The last command should show your AWS identity and Account ID without errors. If errors occur, re-check Step 2 (AWS Credential Config in `.env`).

**You are now ready to proceed with the hands-on exercises!**

## Running Hands-on Exercises

1.  Ensure the `workspace` container is running (`docker compose ps`).
2.  Access the container's shell (`docker compose exec workspace bash`).
3.  Navigate to the relevant chapter's directory (e.g., `cd chapter04`).
4.  Follow instructions in the book and chapter-specific `README.md`.

## General Cleanup

* **Cloud Resources:** **CRITICAL:** Always run `terraform destroy` (or the specific cleanup command mentioned) at the end of **every** chapter that creates cloud resources. **Do not forget this step, or you WILL continue to be charged by AWS.** Verify resource deletion in the AWS Console afterwards.
* **Docker Environment:** When finished with your session, stop and remove the container/network: `docker compose down` (add `-v` to remove volumes if needed).

## General Cost Warning

Creating AWS resources **may incur costs**. Review pricing, use Free Tier cautiously, and **always clean up** promptly. Use is at your own risk.