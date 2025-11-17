# incidentresponse-crcz

This repository gathers only the materials required to run the practical exercises of the **CyberRangeCZ** initiative. It does not include generic infrastructure or dependencies from the KYPO/CRCZ laboratory; every asset focuses on the operational workflow currently validated for CYNET subcase 1a of the architecture diagram.

## Scope of the exercises

- **Subcase 1a – Instructor-led training**: outlines the educational dynamic involving the instructor, the Random Education Platform (REP) and the participants.

The detailed flow is summarised below to facilitate reproduction during the practical sessions.

See Figure 6 for the complete CYNET activity diagram.

![Figure 6: CYNET Activity Diagram](docs/figures/cynet-activity.png)

*Figure 6. Activity diagram illustrating how the CYNET platform canalises the instructor-led sequence for subcase 1a.*

## Subcase 1a flow

1. **Instructor preparation**
   - The instructor reviews the exercise guide and configures the session in the REP with the modules that match the topic of the day.
   - Collaborative tools (chat, videoconferencing, digital whiteboard) that accompany the session are enabled.
2. **Session on the Random Education Platform (REP)**
   - The instructor starts broadcasting the content and shares the objectives.
   - The REP automatically assigns each participant a personalised itinerary that combines short theory, simulated scenarios and reminders of good practice.
3. **Formative quizzes for trainees**
   - Trainees complete interactive quizzes in the REP to validate immediate understanding.
   - The instructor monitors the results in real time and provides targeted feedback.
4. **Assessed practical tests**
   - The REP generates supervised practical exercises (virtual labs or short challenges).
   - The results are recorded and consolidated into a report that the instructor reviews with the group during the final feedback.

## Key files

- `training_linear.json`: lists the learning modules for subcase 1a, including step-by-step activities and the tools involved.
- `topology.yml`: describes the CyberRangeCZ components relevant to the exercises and how they integrate with the educational and operational tooling.
- `docs/`: support materials and complementary guides. `docs/provisioning-guide.md` explains how to deploy the infrastructure required for subcase 1a.
- `inventory.sample`: template inventory with placeholder credentials; load secrets at runtime via Ansible Vault or environment variables instead of committing them to version control.
- `provisioning/`: KYPO/CRCZ topology files and Ansible playbooks that replicate the infrastructure defined in the CYNET activity diagram for the 1a flow.

## Validating the repository

Basic structural checks are provided to confirm that the learning sequence and topology descriptors stay consistent. Install the development dependencies and run the automated validation suite with:

```bash
pip install -r requirements-dev.txt
pytest
```

The tests verify that:

- `training_linear.json` follows the expected layout, with sequential steps and non-empty metadata for each activity.
- `topology.yml` only references components defined within the document.
- The KYPO topology in `provisioning/` references valid hosts, routers and networks in its mapping sections.

## Binary assets and diagram contributions

- Keep versioned binary assets to a minimum. Only instructional diagrams that are documented in `docs/figures/` should be committed; all other binaries should be supplied through external links or via Git LFS if your workflow allows it.
- Preferred diagram formats are **PNG** and **SVG** generated from source files so they remain reproducible. Avoid uploading screenshots or raster captures—especially those containing sensitive environments—to git history.
- If you need to share a one-off artifact (e.g., a capture or large archive), attach it through your collaboration platform instead of committing it to the repository.
- A local pre-commit hook is provided to block accidental commits of disallowed binary extensions and to enforce that new PNG/SVG files live under `docs/figures/`. Install it with `pip install pre-commit` and run `pre-commit install` before committing changes.

## Credential management

Before executing Ansible playbooks, replace the password placeholders in `inventory.sample` by referencing secrets stored in Ansible Vault files or exported through environment variables. This keeps sensitive credentials out of the repository while preserving a working inventory template for the exercises.

## Licence

The content is provided strictly for educational purposes.
