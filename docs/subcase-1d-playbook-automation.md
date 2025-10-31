# Subcase 1d – Playbook Automation in the NG-SOC Ecosystem

This document summarises the activities carried out in the operational environment formed by NG-SOC, NG-SIEM, NG-SOAR, the CICMS Operator, CTI-SS and the playbook/standards library (NVD/NIST, MITRE ATT&CK) during the execution of subcase 1d.

## Operational flow
1. **Alert generation in NG-SIEM**
   - NG-SIEM correlates telemetry events and produces a prioritised alert that includes key indicators and affected assets.
   - The alert is sent to the NG-SOC console together with the initial recommendations based on correlation rules.
2. **Validation in NG-SOC**
   - The analyst reviews the alert, selects the appropriate CACAO playbook from the NG-SOC repository and defines the execution parameters.
   - The selection is checked against the playbook/standards library to ensure coverage of MITRE ATT&CK and NVD/NIST references.
3. **Orchestration via NG-SOAR**
   - NG-SOC orchestrates the execution by delegating to NG-SOAR, which interprets the CACAO sequence and coordinates automated tasks.
   - NG-SOAR connectors consult CTI-SS to enrich indicators and validate reputation.
4. **Coordination with CICMS Operator**
   - When the playbook requires manual interventions or validations, NG-SOAR synchronises the milestones with the CICMS operator.
   - CICMS Operator consolidates evidence, updates the incident status and prepares the post-incident report.
5. **Documentation and learning with the playbook library**
   - At the end of each phase, NG-SOAR publishes the results in NG-SOC and NG-SIEM, while CICMS Operator records relevant decisions.
   - References in the library (MITRE ATT&CK, NVD/NIST) are updated with lessons learnt and links to recent CTI.

## Practical exercises
### Exercise 1: Ransomware in critical infrastructure
- **Objective:** validate early detection and automatic containment of a mass encryption attack.
- **Operational phases:**
  1. *Detection*: NG-SIEM identifies anomalous encryption patterns and raises the prioritised alert.
  2. *Containment*: NG-SOAR runs the CACAO playbook to isolate critical endpoints and revoke suspicious credentials.
  3. *Recovery*: CICMS coordinates with continuity teams to restore backups and verify integrity.
- **Platform interaction:** NG-SIEM feeds NG-SOAR with artefacts to automate the response; NG-SOAR invokes resilient connectors towards CTI-SS to validate indicators and towards the playbook library to confirm MITRE ATT&CK coverage; CICMS documents decisions and updates the recovery status, while NG-SOC supervises the end-to-end execution.

### Exercise 2: Data exfiltration through encrypted channel
- **Objective:** ensure the ecosystem coordinates the investigation and blocking of malicious communications to external services.
- **Operational phases:**
  1. *Correlation*: NG-SIEM cross-references network flows with CTI-SS intelligence to identify command-and-control addresses.
  2. *Orchestration*: NG-SOC selects the CACAO playbook that instructs NG-SOAR to deploy firewall rules and request evidence from DLP tools.
  3. *Analysis and closure*: CICMS centralises the evidence, while the playbook library stores the indicators for future reference.
- **Platform interaction:** NG-SOAR maintains redundant connectors towards network devices to guarantee enforcement of the blocks; CTI-SS provides enriched indicators; CICMS records approvals and the technical rationale, and NG-SOC adjusts the strategy based on the reports from NG-SIEM and NG-SOAR.

### Exercise 3: Compromise of privileged credentials
- **Objective:** assess the capability to detect, respond to and remediate compromised privileged access.
- **Operational phases:**
  1. *Initial alert*: NG-SIEM detects suspicious activity on privileged accounts based on behavioural anomalies.
  2. *Co-ordinated response*: NG-SOC selects a credential rotation playbook that NG-SOAR runs to revoke access, generate temporary credentials and notify those responsible.
  3. *Verification and lessons*: CICMS confirms that controls have been reinstated, while the playbook library incorporates the improvements and CTI-SS adds related signatures.
- **Platform interaction:** NG-SOAR ensures the resilience of connectors to identity management systems; NG-SIEM monitors events after the rotation; CICMS updates the documentation and impact metrics, and NG-SOC uses the playbook library to propose strategic adjustments and produce additional training.

## Assessment criteria
- Correct selection of the CACAO playbook in NG-SOC according to the alert's initial classification.
- Complete execution of the automated actions in NG-SOAR without failures in critical connectors.
- Timely synchronisation of milestones in CICMS Operator, including required evidence and approvals.
- Recording of lessons learnt in the playbook library, linking applied MITRE ATT&CK controls and NVD/NIST references.
- Resilience of the connectors orchestrated by NG-SOAR and NG-SOC, validating redundancies and documented contingency plans.
- Comprehensive documentation in CICMS Operator, including procedures followed, final indicators and the person responsible for each action.
- Incorporation and monitoring of post-incident metrics (containment time, recovery time, residual impact) recorded in NG-SIEM, NG-SOAR and CICMS.

## Automatic platform feedback
- NG-SIEM generates a detection quality score based on correlation accuracy and displays it on the NG-SOC console.
- NG-SOAR provides a playbook execution report with success metrics per task, highlighting the steps that require review.
- CICMS Operator issues alerts when a manual milestone remains pending and preserves the traceability required for audit.
- The playbook library publishes an updated summary with references to MITRE ATT&CK, NVD/NIST and recent CTI for future incidents.
- Connectors monitored by NG-SOAR report resilience indicators (latency, availability, retries) to support preventive adjustments.
- CICMS Operator generates automatic reminders to complete pending documentation and compare it with internal guidelines.
- Consolidated post-incident metrics (MTTD, MTTR, containment effectiveness) are calculated and compared with thresholds defined within the playbook library.
