# Subcase 1d – Provisioning guide

Automation assets for the NG-SOC ecosystem used during the playbook execution exercises. Each role prepares the baseline required to validate the end-to-end flow between NG-SIEM, NG-SOC, NG-SOAR, CTI-SS, CICMS Operator and the playbook library.

## Host groups

| Inventory group | Hosts | Purpose |
| --- | --- | --- |
| `ng_soc` | `ng-soc` | Analyst console and orchestration entry point. |
| `ng_siem` | `ng-siem` | Event correlation and alerting platform. |
| `ng_soar` | `ng-soar` | Automation engine running CACAO playbooks. |
| `cti_ss` | `cti-ss` | Threat intelligence and indicator enrichment. |
| `cicms` | `cicms-operator` | Incident coordination and documentation workspace. |
| `playbook_library` | `playbook-library` | Standards repository (NVD/NIST, MITRE ATT&CK) and lessons learnt. |
| `telemetry_feeder` | `telemetry-simulator` | Generates telemetry samples for NG-SIEM validation. |

## Requirements

- Ansible 2.15 or newer with the `community.general` collection available. Install the `pywinrm` Python package for WinRM connectivity when managing Windows hosts from the same control node (use `pywinrm[credssp]` where CredSSP is needed).
- Access to the hosts defined in `provisioning/case-1d/topology.yml`.
- Secrets managed through Ansible Vault or environment variables.

Install the collection with:

```bash
ansible-galaxy collection install community.general
```

## Running the playbook

```bash
ansible-playbook -i inventory.ini provisioning/case-1d/provisioning/playbook.yml
```

Use tags to execute individual components, e.g. `--tags ng_siem` to provision only the SIEM server.

## Role functional requirements

### `cicms`
- **Service:** exposes the incident coordination portal with Nginx and routes traffic to the backend on `:9201`.
- **Configuration:** `nginx-cicms.conf.j2` and `settings.json.j2` render the `cicms_nginx_site`, `cicms_tls` and `cicms_cms_settings` variables into the effective configuration and TLS secrets.
- **Validation:** `nginx -t` and a `GET {{ cicms_healthcheck.url }}` request ensure the virtual host responds correctly.

### `cti_ss`
- **Service:** publishes a TAXII server with STIX collections used by NG-SIEM and NG-SOAR.
- **Configuration:** `taxii.yaml.j2` consumes `cti_ss_taxii_collections`, credentials and ports to generate `/etc/cti-ss/taxii.yaml`.
- **Validation:** `cti-ssctl configtest` and `cti_ss_healthcheck_command` verify the daemon syntax and status.

### `ng_siem`
- **Service:** maintains the `rep_ingest` pipeline with TCP and TAXII sources, GeoIP enrichments and an Elasticsearch output.
- **Configuration:** `pipeline.conf.j2` translates `ng_siem_pipeline` into the file under `pipelines.d`.
- **Validation:** the role runs `ng-siemctl pipeline lint` followed by `ng_siem_healthcheck.command` to confirm the pipeline is healthy.

### `ng_soar`
- **Service:** defines orchestration queues and connectors (REST/Kafka) for NG-SOAR automation.
- **Configuration:** `queues.yaml.j2` uses `ng_soar_queues` and `ng_soar_integrations` to publish the queue topology.
- **Validation:** `ng-soarctl validate` plus an HTTP check to `{{ ng_soar_healthcheck.url }}`.

### `ng_soc`
- **Service:** delivers the SOC dashboard with widgets connected to NG-SIEM/NG-SOAR and alert routes.
- **Configuration:** `dashboard.yaml.j2` consumes `ng_soc_widgets` and `ng_soc_alert_routes` to build `/etc/ng-soc/dashboard.yaml`.
- **Validation:** `ng-socctl validate` and an `ansible.builtin.uri` check against `ng_soc_healthcheck.url`.

### `playbook_library`
- **Service:** hosts the CACAO playbooks consumed by NG-SOAR.
- **Configuration:** the `playbook.json.j2` and `index.json.j2` templates serialise `playbook_library_playbooks` into individual files and a global index.
- **Validation:** `playbook_library_healthcheck_command` (defaults to `cacaoctl validate`).

### `telemetry_feeder`
- **Service:** distributes the agent that forwards telemetry and observables to NG-SIEM and CTI-SS.
- **Configuration:** `agent.yaml.j2` reflects `telemetry_feeder_agent` with buffers, transformations and outputs.
- **Validation:** `telemetry-feederctl lint` plus an HTTP query to `telemetry_feeder_healthcheck_url`.

## Parameterisation and checks

The default variables live in `roles/<role>/defaults/main.yml` and cover ports, template paths, CACAO parameters and ingestion credentials. Adjust those values in `group_vars`, the inventory or `--extra-vars` to adapt pipelines, queues and collections to each lab.

Each `tasks/main.yml` applies the templates with idempotent modules (`ansible.builtin.template`, `ansible.builtin.copy`) and triggers handlers for controlled restarts. The final steps include command-line or `ansible.builtin.uri` validations with explicit `failed_when` clauses so any connectivity, syntax or service-status issue stops the deployment and provides immediate traceability.
