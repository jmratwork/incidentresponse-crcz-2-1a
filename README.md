# incidentresponse-crcz

This repository gathers only the materials required to run the practical exercises of the **CyberRangeCZ** initiative. It does not include generic infrastructure or dependencies from the KYPO/CRCZ laboratory; every asset focuses on the operational workflows currently validated for CYNET subcases 1a and 1d of the architecture diagram.

## Scope of the exercises

- **Subcase 1a – Instructor-led training**: outlines the educational dynamic involving the instructor, the Random Education Platform (REP) and the participants.
- **Subcase 1d – NG-SOC operation**: documents how the NG-SOC/NG-SIEM and NG-SOAR components coordinate the automated response with support from the CICMS Operator, CTI-SS and the playbook/standards library (NVD/NIST, MITRE ATT&CK).

The detailed flow for each subcase is summarised below to facilitate reproduction during the practical sessions.

See Figure 6 for the complete CYNET activity diagram.

![Figure 6: CYNET Activity Diagram](docs/figures/cynet-activity.png)

*Figure 6. Activity diagram illustrating how the CYNET platform canalises the instructor-led sequence for subcase 1a and the automated NG-SOC response for subcase 1d.*

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

## Subcase 1d flow

1. **Detection in NG-SOC/NG-SIEM**
   - NG-SIEM receives events from CyberRangeCZ telemetry sources and raises prioritised alerts.
   - The NG-SOC analyst validates the alert and selects the relevant CACAO playbook.
2. **CACAO playbook orchestration**
   - The NG-SOC orchestrator invokes NG-SOAR to run the chosen playbook.
   - NG-SOAR coordinates automated tasks (enrichment, containment and notification) following the CACAO sequence.
3. **Support from transversal systems**
   - **CICMS Operator** centralises incident documentation and channels post-incident reports.
   - **CTI-SS** provides threat intelligence and additional context for decision-making.
   - **Playbook and standards library (NVD/NIST, MITRE ATT&CK)** guides the selection of response and recovery actions.
4. **Closure and feedback**
   - NG-SOAR consolidates the outcomes and returns the final status to NG-SOC/NG-SIEM.
   - CICMS Operator produces the post-incident report and references lessons learnt in the playbook library.

## Key files

- `training_linear.json`: lists the learning modules for subcases 1a and 1d, including step-by-step activities and the tools involved.
- `topology.yml`: describes the CyberRangeCZ components relevant to the exercises and how they integrate with the educational and operational tooling.
- `docs/`: support materials and complementary guides. `docs/provisioning-guide.md` explains how to deploy the infrastructure required for each subcase.
- `inventory.sample`: template inventory with placeholder credentials; load secrets at runtime via Ansible Vault or environment variables instead of committing them to version control.
- `provisioning/`: KYPO/CRCZ topology files and Ansible playbooks that replicate the infrastructure defined in the CYNET activity diagram for the 1a and 1d flows.

## Validating the repository

Basic structural checks are provided to confirm that the learning sequence and topology descriptors stay consistent. Install the development dependencies and run the automated validation suite with:

```bash
pip install -r requirements-dev.txt
pytest
```

The tests verify that:

- `training_linear.json` follows the expected layout, with sequential steps and non-empty metadata for each activity.
- `topology.yml` only references components defined within the document.
- The KYPO topologies in `provisioning/` reference valid hosts, routers and networks in their mapping sections.

## Credential management

Before executing Ansible playbooks, replace the password placeholders in `inventory.sample` by referencing secrets stored in Ansible Vault files or exported through environment variables. This keeps sensitive credentials out of the repository while preserving a working inventory template for the exercises.

## Licence

The content is provided strictly for educational purposes.
