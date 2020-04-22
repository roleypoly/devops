# Roleypoly DevOps

This repo is nearly entirely terraform automation. Access to production/staging systems is extremely locked down, but this is still around for referencing and open improvement.

## Structure

These folders are split into logical parts

- **terraform** - folder with all the terraform stuff, duh
    - **modules** - modules for provisioning and interacting with common systems
        - **nginx-ingress-controller**
        - **cloudflare-dns**
        - **env-service-account**
    - **app** - app workspace, split in TFC by prd/stg var
    - **platform** - terraform cloud platform workspaces
        - **app** - provisioning of service accounts and tf workspaces for app
        - **bootstrap** - bootstraps digitalocean project, vault backend, and platform TFC workspaces
        - **kubernetes** - manages the DO kubernetes cluster
        - **services** - manages basic kubernetes services, like ingresses, LBs, vault, and etc.