# Provisioning workflow for subcase 1a

This guide explains how to instantiate the CyberRangeCZ infrastructure aligned with the CYNET activity diagram. The process is divided into two phases: importing the KYPO/CRCZ topology and configuring the virtual machines with Ansible.

## 1. Import the topology in KYPO/CRCZ

1. Sign in to the KYPO portal with an account that can create sandboxes.
2. Upload `provisioning/case-1a/topology.yml`. The topology creates:
   - REP backend servers (`rep-scheduler`, `rep-live-session`, `rep-quiz-engine`, `rep-practical-labs`).
   - Instructor and trainee workstations connected to the `rep-frontend` network.
   - The `reporting-workspace` node on the analytics segment.
3. Deploy the sandbox and wait for KYPO/CRCZ to report that all machines are reachable.

## 2. Prepare credentials

1. Duplicate `inventory.sample` and rename it to `inventory.ini` (or keep the `.sample` extension).
2. Keep the hostnames and IP addresses defined by the topology files.
3. Export credentials as environment variables before executing Ansible, for example:

```bash
export ANSIBLE_PASSWORD_REP_SCHEDULER='********'
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

```bash
ansible-playbook -i inventory.ini provisioning/playbook.yml
```

The playbook:
- Installs web and application dependencies on the REP backend servers.
- Prepares the reporting workspace dashboards.
- Customises the instructor console.
- Creates working folders for trainee machines.

Use the helper scripts in `provisioning/case-1a/scripts/` to exercise REP services during dry runs:

- `schedule_rep_lab.sh` posts a JSON payload (for example `examples/lab-schedule.json`) to the Scheduler endpoint defined by
  `REP_SCHEDULER_API_BASE` (and optionally `REP_SCHEDULER_SCHEDULE_PATH`).
- `export_quiz_report.sh` downloads quiz analytics from the Reporting Workspace using `REP_REPORTING_API_BASE`; both scripts
  require a bearer token supplied in `REP_API_TOKEN`. Set `REP_REPORTING_EXPORT_PATH` when the Reporting Workspace exposes a
  custom path.

## 5. Validation steps

- Check SSH or WinRM connectivity with `ansible all -i inventory.ini -m ping` (use `ansible.windows.win_ping` for Windows groups).
- Verify that key services are running (`nginx` on the REP backend, quiz engine workers and the Grafana service on the reporting workspace).
- Confirm that trainees can access the `WELCOME.txt` note in `C:\Labs` and that the instructor console has the `rep-notes` workspace.

Following these steps ensures the infrastructure mirrors the flow of subcase 1a and is ready for the exercises described in `docs/subcase-1a-phishing-awareness.md`.
