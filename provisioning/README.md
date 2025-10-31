# Subcase 1a – Provisioning guide

The playbooks in this directory prepare the infrastructure required by the phishing awareness exercises delivered on the Random Education Platform (REP).

## Host groups

| Inventory group | Hosts | Purpose |
| --- | --- | --- |
| `rep_core` | `rep-scheduler`, `rep-live-session`, `rep-quiz-engine`, `rep-practical-labs` | Backend services that coordinate course scheduling, live delivery, quizzes and practical labs. |
| `reporting_workspace` | `reporting-workspace` | Dashboards and report consolidation workspace. |
| `instructor_console` | `instructor-console` | Entry point for instructors to manage the live session. |
| `trainees` | `trainee-workstation-01`, `trainee-workstation-02` | Windows workstations used by participants during the labs. |

## Requirements

- Ansible 2.15 or newer with the `ansible.windows` and `community.general` collections installed, plus the `pywinrm` Python package for WinRM connectivity (use `pywinrm[credssp]` when the scenario requires CredSSP).
- Network reachability towards the hosts defined in `provisioning/subcase-1a-topology.yml`.
- Credentials provided through Ansible Vault files or environment variables (see `inventory.sample`).

Install the collections with:

```bash
ansible-galaxy collection install ansible.windows community.general
```

## Running the playbook

1. Export sensitive variables or prepare an Ansible Vault file that contains the required passwords.
2. Copy `inventory.sample` to `inventory.ini` (or keep the `.sample` file) and adjust the host addresses if necessary.
3. Execute the site playbook:

```bash
ansible-playbook -i inventory.ini provisioning/subcase-1a/site.yml
```

## Role functional requirements

### `rep_core`
- **Service:** publishes the REP platform behind Nginx with load balancing towards the `scheduler`, `live_session` and `quiz_engine` microservices.
- **Configuration:** the `templates/nginx-rep-core.conf.j2` file renders the TLS virtual host and the upstreams defined in `defaults/main.yml` (`rep_core_virtual_host` and `rep_core_tls`). It also protects a shared secret stored in `rep_core_shared_secret_file`.
- **Key variables:** `rep_core_virtual_host.*`, `rep_core_tls.*`, `rep_core_shared_secret` and `rep_core_healthcheck` describe routes, certificates and health checks.
- **Validation:** `tasks/main.yml` runs `nginx -t` and an `ansible.builtin.uri` call to the `healthcheck_path`, raising an error if the HTTP code differs from the expected value.

### `reporting_workspace`
- **Service:** provisions Grafana with PostgreSQL data sources and dashboards to monitor the exercise.
- **Configuration:** the `grafana.ini.j2`, `datasources.yaml.j2`, `dashboards.yaml.j2` and `dashboard.json.j2` templates generate the Grafana configuration and the dashboards listed in `reporting_workspace_dashboards`.
- **Key variables:** `reporting_workspace_datasources`, `reporting_workspace_dashboards`, `reporting_workspace_grafana_ini` and `reporting_workspace_healthcheck` allow you to parameterise ports, dashboards and checks.
- **Validation:** after applying the templates the role issues a `GET {{ reporting_workspace_healthcheck.url }}` request and expects `database == 'ok'`.

### `instructor_console`
- **Service:** prepares the instructor's terminal with predefined `tmux` sessions and shell shortcuts to the critical services.
- **Configuration:** `tmux.conf.j2` and `instructor-console.sh.j2` translate `instructor_console_tmux_settings` and `instructor_console_shortcuts` into files in `$HOME` and `/etc/profile.d`.
- **Key variables:** `instructor_console_user`, `instructor_console_workspace`, `instructor_console_tmux_settings` and `instructor_console_shortcuts`.
- **Validation:** the role runs `tmux -f … display-message` and a `bash -lc` command to verify that the shortcuts are registered as functions.

### `trainee_workstation`
- **Service:** distributes the REP Collector agent configuration, the shortcuts on participants' Windows desktops and the lab welcome message.
- **Configuration:** `ansible.windows.win_template` renders `collector.yaml` and the `.url` shortcuts described in `trainee_workstation_shortcuts`, while `ansible.windows.win_copy` publishes the `WELCOME.txt` note in `{{ trainee_workstation_welcome_note.directory }}`.
- **Key variables:** `trainee_workstation_collector.*` (path, service and transports), `trainee_workstation_shortcuts` and `trainee_workstation_welcome_note.*` (directory, name and message content).
- **Validation:** the service state is checked with `Get-Service` and restarts automatically if the templates change.

## Parameterisation and checks

Each role exposes its default configuration in `roles/<role>/defaults/main.yml`. Adjust those variables in the inventory, `group_vars` or `-e` parameters to customise hosts, certificates, ingestion targets or shortcuts without modifying the templates.

The `tasks/main.yml` file for each role applies the configuration idempotently via `ansible.builtin.template`/`ansible.windows.win_template` and registers handlers to restart services when required. The final tasks include post-configuration verifications (HTTP checks, `nginx -t`, `tmux`, `Get-Service`, etc.) with explicit `failed_when` conditions so execution stops if the services do not respond as expected.
