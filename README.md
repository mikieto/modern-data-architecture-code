# Modern Data Architecture Hands-on Code Repository

Welcome! This repository contains the companion code for the book "Building Modern Data Architectures". It provides hands-on exercises using Docker and AWS to help you build and operate a modern data platform step-by-step.

This README provides essential instructions for setting up your environment.

**⚠️ IMPORTANT: AWS COSTS & RESOURCE CLEANUP ⚠️**

* The hands-on exercises **will create real AWS resources that incur costs.**
* It is **CRUCIAL** to **destroy** resources using `terraform destroy` (from the correct directory, e.g., `/work/build/terraform/`) when finished with each chapter or taking breaks.
* **Failure to clean up resources WILL result in ongoing charges.** Use cloud resources responsibly and at your own risk.

## Repository Structure Overview

This repository contains:

* **Configuration Files (Root):** `Dockerfile`, `docker-compose.yml`, `.env.example`, `.gitignore`, `README.md` (this file).
* **Chapter Templates (`chapterXX/`):** Read-only templates for each chapter's hands-on exercises (e.g., `chapter04/`, `chapter05/`). These represent the **starting state** for each chapter.
* **Working Directory (`build/`):** This directory **must be created by you** at the repository root. All your work (copied templates, generated files like Terraform state) will reside here. It is **ignored by Git** due to the `.gitignore` configuration.

<details>
<summary>Click to see the Target Structure within the 'build/' directory (End Goal)</summary>

```plaintext
build/                # Reader's working directory (CREATED BY READER, gitignored)
├── airflow/          # Airflow related files (DAGs, etc.)
│   └── dags/
├── dbt/              # dbt project files (models, etc.)
│   └── models/
├── kafka/            # Kafka related files (scripts, etc.)
├── mlops/            # MLOps related files (notebooks, etc.)
├── scripts/          # Utility scripts
└── terraform/        # Terraform files (managed cumulatively)
    ├── .terraform/   # (Generated, gitignored)
    ├── modules/      # Terraform Modules (if used)
    │   └── ...
    │
    ├── main.tf       # Main configuration (updated as chapters progress)
    ├── variables.tf  # Variables (updated as chapters progress)
    ├── outputs.tf    # Outputs (updated as chapters progress)
    ├── providers.tf  # Provider configurations
    ├── s3.tf         # Example: Resource definitions grouped by function
    ├── iam.tf        # Example: Resource definitions grouped by function
    ├── network.tf    # Example: Resource definitions grouped by function
    ├── ...           # Other .tf files as needed
    │
    ├── terraform.tfstate       # Terraform state (cumulative, gitignored)
    └── terraform.tfstate.backup # Terraform state backup (gitignored)

# Note: This is the target structure representing the development goal.
# Actual file names/details may vary. The `.env` file resides in the repository root.
````

\</details\>

## Prerequisites

Ensure you have the following installed on your host machine:

  * **Git:** To clone this repository. (`git --version`)
  * **Docker:** We strongly recommend Docker for a consistent environment.
      * macOS: Docker Desktop for Mac.
      * Windows: Docker Desktop for Windows (WSL2 backend recommended). Ensure WSL2 integration is enabled in Docker settings.
      * Linux: Docker Engine.
      * **Verify:** Docker daemon/service must be running. Check with `docker ps`.
      * **License:** Review Docker Desktop's licensing terms.
  * **AWS Account & Credentials:** An active AWS account and valid AWS Access Key ID & Secret Access Key (temporary credentials recommended).

## Getting Started: One-Time Environment Setup

Follow these steps **once** from your terminal (use WSL2 terminal on Windows) before starting Chapter 4.

**1. Clone Repository:**

```bash
# Replace with the actual repository URL
git clone [https://github.com/mikieto/modern-data-architecture-code.git](https://github.com/mikieto/modern-data-architecture-code.git)
cd modern-data-architecture-code
```

*(Run subsequent setup commands from the repository root directory.)*

**2. Create Working Directory:**

```bash
mkdir build
```

*(This `build/` directory is where you'll perform all hands-on work. It's ignored by Git.)*

**3. Configure AWS Credentials (CRITICAL):**

  * Copy the template: `cp .env.example .env` (in the repository root).
  * Edit the `.env` file with a text editor.
  * **Carefully follow the instructions within `.env.example`** to provide your AWS credentials (Option A: Temporary - Recommended, or Option B: Long-term IAM User) and set your desired `AWS_DEFAULT_REGION` (e.g., `us-east-1`).
  * Save the `.env` file. **Never commit this file to Git.** (`.gitignore` prevents this).

**4. Verify Docker is Running:**

  * Ensure the Docker Desktop application or Docker service is running.
  * (Windows WSL2 users): Double-check WSL integration is enabled in Docker Desktop settings.
  * Run `docker ps` in your terminal. It should execute without connection errors.

**5. Build & Start Docker Container:**

  * Build the image: `docker compose build workspace`
  * Start the container in the background: `docker compose up -d workspace`
  * Check status: `docker compose ps` (should show `mda_workspace` running).

**6. Connect to Container Shell:**

  * This is where you'll run most hands-on commands:
    ```bash
    docker compose exec workspace bash
    ```
  * You'll see a prompt like `root@<container_id>:/work#`. The repository code is mounted at `/work`.

**7. Verify Setup Inside Container:**

  * Run: `terraform --version && aws --version && aws sts get-caller-identity`
  * The last command should show your AWS identity without errors. If errors occur, double-check your `.env` file (Step 3).

**You are now ready for the hands-on chapters\!**

## Running Hands-on Exercises (Chapter 4 onwards)

**General Workflow for Each Chapter:**

1.  **Ensure Container is Running:** Check with `docker compose ps` (on host). If needed, start with `docker compose up -d workspace` (from repo root on host).
2.  **Connect to Container Shell:** `docker compose exec workspace bash` (on host).
3.  **Navigate to Working Directory:** Move to the appropriate directory within the container, based on the tool being used (as instructed in the chapter). Examples:
    ```bash
    # For Terraform tasks (usually)
    cd /work/build/terraform/

    # For dbt tasks (usually)
    cd /work/build/dbt/
    ```
4.  **Copy Chapter Templates:** Copy the template files for the **current chapter** from `/work/chapterXX/` into your **current working directory** (e.g., `/work/build/terraform/`).
    ```bash
    # Example for Chapter 5 Terraform files:
    # (Run from /work/build/terraform/)
    cp -r /work/chapter05/terraform/* .
    ```
    **IMPORTANT NOTE (Reset Behavior):** Copying templates **will overwrite** existing files in your working directory (except `.env`). This ensures you start each chapter with the correct state. Any manual modifications you made in the previous chapter (other than `.env`) **will likely be reset**. Plan your customizations for *after* completing the main hands-on flow.
5.  **Follow Book Instructions:** Execute the commands and perform the steps outlined in the book chapter, running commands from within the correct working directory inside the container.
6.  **Verify Results:** Check command outputs, AWS console, generated data, etc., as instructed.

## Cleanup

  * **Cloud Resources (CRITICAL):** At the end of **each chapter** that creates AWS resources, run `terraform destroy` from the **correct working directory** (e.g., `/work/build/terraform/`) inside the container. **Do not skip this step\!** Verify deletion in the AWS Console.
  * **Docker Environment:** When finished with your session, stop and remove the container/network by running `docker compose down` from the **repository root** on your host machine.

## General Cost Warning (Reminder)

Creating AWS resources **may incur costs**. Review pricing, use Free Tier cautiously, and **always clean up promptly.** Your use is at your own risk.