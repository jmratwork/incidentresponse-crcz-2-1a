# Provisioning artefacts for CyberRangeCZ

The `provisioning/` directory contains topology definitions and Ansible playbooks that reproduce the infrastructure flows of subcases 1a and 1d from the CYNET activity diagram.

## Topology files

- `subcase-1a-topology.yml` – KYPO/CRCZ topology describing the Random Education Platform (REP) components used in the phishing awareness exercise.
- `subcase-1d-topology.yml` – KYPO/CRCZ topology for the NG-SOC, NG-SIEM, NG-SOAR, CTI-SS, CICMS Operator, playbook library and telemetry simulator services.

These files can be imported into KYPO to instantiate the virtual machines, routers and networks ahead of running the configuration playbooks.

## Playbooks

- `subcase-1a/` – Roles and site playbook that prepare REP backends, the instructor console, trainee workstations and the reporting workspace.
- `subcase-1d/` – Roles and site playbook to configure NG-SOC automation components, intelligence services and the telemetry generator.

Each subdirectory includes a README with prerequisites, variable references and execution instructions. Install the required Ansible collections before running the playbooks and store credentials using Ansible Vault or environment variables instead of plain text files.
