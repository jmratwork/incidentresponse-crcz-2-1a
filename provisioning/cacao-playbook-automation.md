# Automated procedures for CACAO playbooks in NG-SOAR

This document replaces traditional deployment scripts and explains how to automate the lifecycle of CACAO playbooks within NG-SOAR, ensuring synchronisation with CICMS Operator, CTI-SS and the playbook library. The automations rely on APIs available in the Subcase 1d components and can be run from any console with authenticated access. All helper scripts live in [`provisioning/scripts`](./scripts) and require the following environment variables:

```bash
export SOC_USER="<soc username>"
export SOC_PASS="<soc password>"
export NG_SOC_API_BASE="https://ng-soc.example/api"
export NG_SOAR_API_BASE="https://ng-soar.example/api"
export CICMS_API_BASE="https://cicms.example/api"
export PLAYBOOK_LIBRARY_API_BASE="https://playbooks.example/api"   # update_playbook.sh only
export CTISS_API_BASE="https://cti-ss.example/api"                  # share_playbook.sh only
```

> **Tip:** adjust the HTTPS endpoints to the deployment that is being exercised. The scripts stop with a descriptive error if any dependency is missing or an endpoint variable is not defined.

> **Prerequisites:** the examples use [HTTPie](https://httpie.io/) with the `--check-status` and `--print=b` (`-b`) options to ensure that any post-processing, such as [`jq`](https://stedolan.github.io/jq/), operates solely on the JSON body returned by the API and so that scripts fail on unsuccessful HTTP codes.
> - On Debian/Ubuntu, install both tools with `sudo apt-get install httpie jq`.
> - On macOS with Homebrew, install them with `brew install httpie jq`.

Both HTTPie and `jq` are required to execute `create_playbook.sh`, `update_playbook.sh` and `share_playbook.sh`.

## 1. Playbook creation

```bash
./provisioning/scripts/create_playbook.sh provisioning/scripts/examples/playbook-create.json
```

- The first call registers the playbook in the NG-SOC central repository.
- The second call imports it into NG-SOAR so it is available in the execution queues.
- The third records the material in CICMS Operator so the operations team has the latest context.
- Each creation script should be stored together with the corresponding references in the playbook library.

## 2. Updating and versioning

```bash
./provisioning/scripts/update_playbook.sh playbook--example-create provisioning/scripts/examples/playbook-update.json
```

- The update synchronises NG-SOC and NG-SOAR with the new version and records the change in the playbook library.
- The library keeps the version history and the release notes.

## 3. Distribution and sharing with CTI-SS

```bash
./provisioning/scripts/share_playbook.sh playbook--example-create canal-general
```

- NG-SOAR exposes the playbook in CACAO format and CTI-SS replicates it to the targeted intelligence channels.
- **Note:** using `:=` in HTTPie prevents the JSON from being escaped again and forwards it unmodified to CTI-SS.
- CTI-SS adds tags and taxonomies before redistributing the content.
- The process is logged in CICMS Operator and in the library to maintain traceability.

## 4. Integrations with CICMS Operator and the playbook library
- Each script records metadata in CICMS Operator and in the library (`/library/register`) to preserve traceability.
- NG-SOC leads review of the CICMS Operator dashboard every week to confirm there are no discrepancies between versions.
- When a playbook reaches a stable state, a summary is created in the library with references to the CTI-SS sources used.

## 5. Local examples and automated tests

- Sample CACAO playbooks for quick validation live in [`provisioning/scripts/examples`](./scripts/examples).
- Lightweight regression tests based on [`bats`](https://github.com/bats-core/bats-core) exercise the error handling without reaching the real APIs. Execute them with:

```bash
bats provisioning/scripts/tests/playbook_scripts.bats
```

> The tests mock the `http` and `jq` binaries so that the scripts can be validated offline, while still respecting the expected error codes when the APIs fail.

## 6. Replacement of the KYPO infrastructure
- These automations run within the NG ecosystem itself and remove the dependency on the KYPO infrastructure.
- No external machines or additional deployments are required: service credentials and secure connectivity are sufficient.
- Documentation and scripts are hosted in the playbook library associated with Subcase 1d.
