import json
from pathlib import Path

import pytest
import yaml

REPO_ROOT = Path(__file__).resolve().parents[1]


@pytest.fixture(scope="module")
def training_data():
    training_file = REPO_ROOT / "training_linear.json"
    with training_file.open("r", encoding="utf-8") as f:
        return json.load(f)


def test_training_linear_structure(training_data):
    assert isinstance(training_data, dict)
    for key in ("name", "description", "modules"):
        assert key in training_data, f"Missing key '{key}' in training file"

    modules = training_data["modules"]
    assert isinstance(modules, list) and modules, "Modules list must not be empty"

    for module in modules:
        assert set(module.keys()) >= {"id", "title", "phases"}
        assert module["id"]
        assert module["title"].strip()
        phases = module["phases"]
        assert isinstance(phases, list) and phases

        steps = []
        for phase in phases:
            assert set(phase.keys()) >= {"name", "activities"}
            assert phase["name"].strip()
            activities = phase["activities"]
            assert isinstance(activities, list) and activities
            for activity in activities:
                assert set(activity.keys()) >= {"step", "description", "tools"}
                steps.append(activity["step"])
                assert isinstance(activity["step"], int)
                assert activity["description"].strip()
                tools = activity["tools"]
                assert isinstance(tools, list) and tools
                for tool in tools:
                    assert isinstance(tool, str) and tool.strip()

        sorted_steps = sorted(steps)
        expected_steps = list(range(1, len(sorted_steps) + 1))
        assert sorted_steps == expected_steps, (
            f"Module {module['id']} steps should be sequential starting at 1"
        )


@pytest.fixture(scope="module")
def topology_data():
    topology_file = REPO_ROOT / "topology.yml"
    with topology_file.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def test_topology_components_are_consistent(topology_data):
    assert "name" in topology_data

    components = topology_data.get("components")
    if not components:
        pytest.skip("Topology file does not declare component metadata")

    assert isinstance(components, dict)

    for component, attrs in components.items():
        assert "purpose" in attrs and attrs["purpose"].strip()
        integrations = attrs.get("integrations", [])
        assert isinstance(integrations, list)
        for target in integrations:
            assert target in components, (
                f"Component '{component}' integrates with unknown target '{target}'"
            )


@pytest.mark.parametrize(
    "topology_path",
    [REPO_ROOT / "provisioning" / "case-1a" / "topology.yml"],
)
def test_provisioning_topologies(topology_path):
    if not topology_path.exists():
        pytest.skip(f"Topology definition {topology_path.name} not present in repository")

    with topology_path.open("r", encoding="utf-8") as f:
        data = yaml.safe_load(f)

    for key in ("name", "hosts", "routers", "networks", "net_mappings", "router_mappings"):
        assert key in data, f"Missing '{key}' in {topology_path.name}"

    hosts = {host["name"] for host in data["hosts"]}
    routers = {router["name"] for router in data["routers"]}
    networks = {net["name"] for net in data["networks"]}

    assert len(hosts) == len(data["hosts"]), "Duplicate host names detected"
    assert len(routers) == len(data["routers"]), "Duplicate router names detected"
    assert len(networks) == len(data["networks"]), "Duplicate network names detected"

    for mapping in data["net_mappings"]:
        assert mapping["host"] in hosts, (
            f"Mapping references unknown host '{mapping['host']}' in {topology_path.name}"
        )
        assert mapping["network"] in networks, (
            f"Mapping references unknown network '{mapping['network']}' in {topology_path.name}"
        )

    for mapping in data["router_mappings"]:
        assert mapping["router"] in routers, (
            f"Router mapping references unknown router '{mapping['router']}' in {topology_path.name}"
        )
        assert mapping["network"] in networks, (
            f"Router mapping references unknown network '{mapping['network']}' in {topology_path.name}"
        )


def load_yaml(relative_path):
    target = REPO_ROOT / relative_path
    with target.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def test_reporting_workspace_healthcheck_defaults_expose_fallbacks():
    defaults = load_yaml("provisioning/roles/reporting-workspace/defaults/main.yml")
    healthcheck = defaults["reporting_workspace_healthcheck"]

    assert "status_code_alternatives" in healthcheck
    assert isinstance(healthcheck["status_code_alternatives"], list)
    assert "failed_when_non_json" in healthcheck
    assert healthcheck["failed_when_non_json"].strip()


def test_reporting_workspace_health_task_handles_non_json_payloads():
    tasks = load_yaml("provisioning/roles/reporting-workspace/tasks/main.yml")
    health_tasks = [task for task in tasks if task.get("name") == "Validate Grafana is responding"]

    assert health_tasks, "Health validation task should exist"
    health_task = health_tasks[0]

    uri_config = health_task["ansible.builtin.uri"]
    status_code_expr = uri_config["status_code"]
    assert "status_code_alternatives" in status_code_expr

    failed_when = health_task["failed_when"]
    assert isinstance(failed_when, list) and len(failed_when) == 2
    assert "reporting_workspace_health.json is not defined" in failed_when[0]
    assert "failed_when_non_json" in failed_when[0]
    assert "reporting_workspace_health.json is defined" in failed_when[1]
