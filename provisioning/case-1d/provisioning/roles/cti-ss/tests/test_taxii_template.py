from __future__ import annotations

import json
from pathlib import Path

from jinja2 import Environment, FileSystemLoader


def render_template(**variables: object) -> str:
    template_dir = Path(__file__).resolve().parents[1] / "templates"
    env = Environment(loader=FileSystemLoader(str(template_dir)))
    env.filters["to_json"] = lambda value: json.dumps(value)

    template = env.get_template("taxii.yaml.j2")
    return template.render(**variables)


def test_strings_with_special_characters_are_quoted() -> None:
    rendered = render_template(
        cti_ss_bind_host="127.0.0.1",
        cti_ss_bind_port=9000,
        cti_ss_taxii_collections=[
            {
                "id": "collection#1",
                "title": "Indicators with spaces",
                "description": "Contains #hash and spaces",
                "can_read": ["user one", "user#two"],
                "can_write": ["writer three"],
            }
        ],
        cti_ss_auth={
            "users": [
                {
                    "username": "analyst user",
                    "password": "pa#ss word",
                    "permissions": ["collection#1:read"],
                }
            ]
        },
    )

    assert 'id: "collection#1"' in rendered
    assert 'title: "Indicators with spaces"' in rendered
    assert 'description: "Contains #hash and spaces"' in rendered
    assert '- "user one"' in rendered
    assert '- "user#two"' in rendered
    assert 'username: "analyst user"' in rendered
    assert 'password: "pa#ss word"' in rendered
    assert '- "collection#1:read"' in rendered


if __name__ == "__main__":
    # Allow running as a simple smoke check without pytest.
    test_strings_with_special_characters_are_quoted()
    print("taxii.yaml.j2 template quoting test passed")
