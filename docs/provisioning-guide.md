# Provisioning workflow for subcases 1a and 1d

This guide explains how to instantiate the CyberRangeCZ infrastructure aligned with the CYNET activity diagram. The process is divided into two phases: importing the KYPO/CRCZ topology and configuring the virtual machines with Ansible.

## 1. Import the topology in KYPO/CRCZ

1. Sign in to the KYPO portal with an account that can create sandboxes.
2. For subcase **1a**, upload `provisioning/subcase-1a-topology.yml`. The topology creates:
   - REP backend servers (`rep-scheduler`, `rep-live-session`, `rep-quiz-engine`, `rep-practical-labs`).
   - Instructor and trainee workstations connected to the `rep-frontend` network.
   - The `reporting-workspace` node on the analytics segment.
3. For subcase **1d**, upload `provisioning/subcase-1d-topology.yml` to provision:
   - Core NG-SOC hosts (`ng-soc`, `ng-siem`, `ng-soar`).
   - Supporting services (`cti-ss`, `cicms-operator`, `playbook-library`, `telemetry-simulator`).
   - Segmented networks that emulate the SOC, automation, intelligence, coordination and telemetry zones.
4. Deploy the sandbox and wait for KYPO/CRCZ to report that all machines are reachable.

## 2. Prepare credentials

1. Duplicate `inventory.sample` and rename it to `inventory.ini` (or keep the `.sample` extension).
2. Keep the hostnames and IP addresses defined by the topology files.
3. Export credentials as environment variables before executing Ansible, for example:

```bash
export ANSIBLE_PASSWORD_REP_SCHEDULER='********'
export ANSIBLE_PASSWORD_NG_SOC='********'
```

4. If you prefer to store secrets in Ansible Vault files, replace the `lookup('env', ...)` expressions with `ansible-vault` variables and reference the vault when running the playbooks.

## 3. Install Ansible dependencies

```bash
python3 -m pip install --upgrade ansible
python3 -m pip install pywinrm
ansible-galaxy collection install ansible.windows community.general
```

- Install `pywinrm` to enable Ansible WinRM connectivity. Use `python3 -m pip install "pywinrm[credssp]"` when the sandbox requires CredSSP delegation support.
- Windows connectivity for trainee machines requires WinRM over TLS (port 5986). Configure certificates or use the inventory option `ansible_winrm_server_cert_validation=ignore` for lab environments.

## 4. Execute the playbooks

### Subcase 1a

```bash
ansible-playbook -i inventory.ini provisioning/subcase-1a/site.yml
```

The playbook:
- Installs web and application dependencies on the REP backend servers.
- Prepares the reporting workspace dashboards.
- Customises the instructor console.
- Creates working folders for trainee machines.

### Subcase 1d

```bash
ansible-playbook -i inventory.ini provisioning/subcase-1d/site.yml
```

This playbook configures the NG ecosystem by installing packages, enabling services and seeding working directories that match the operational flow described in the NG-SOC documentation.

Use tags (e.g. `--tags ng_soar`) to target specific components during troubleshooting.

## 5. Validation steps

- Check SSH or WinRM connectivity with `ansible all -i inventory.ini -m ping` (use `ansible.windows.win_ping` for Windows groups).
- Verify that key services are running (`nginx` on the playbook library, `redis-server` on NG-SOAR, `grafana-server` on the reporting workspace).
- Trigger the telemetry simulator script (`/opt/telemetry-simulator/scenarios/generate.sh`) and confirm that NG-SIEM receives events through `rsyslog`.
- Confirm that trainees can access the `WELCOME.txt` note in `C:\Labs` and that the instructor console has the `rep-notes` workspace.

Following these steps ensures the infrastructure mirrors the flows of subcases 1a and 1d and is ready for the exercises described in `docs/subcase-1a-phishing-awareness.md` and `docs/subcase-1d-playbook-automation.md`.
