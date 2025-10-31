# Enabling the Random Education Platform and NG services for Subcase 1d

This artefact describes the activities required to make the Random Education Platform (REP) and the NG-SOC, NG-SIEM, NG-SOAR, CICMS Operator, CTI-SS and playbook library services available during the Subcase 1d exercises. The information is presented as activation procedures rather than instructions for deploying from scratch; it assumes the components already exist in CyberRangeCZ and only require configuration and interconnection.

## Random Education Platform (REP)
1. **Verify active modules**: enable *Scheduler*, *Live Session*, *Quiz Engine* and *Practical Labs* from the administration panel.
2. **Connect with the instructor**: link the instructor console and the reporting area by selecting the relevant class in the calendar.
3. **Synchronise simulators**: confirm that the CyberRangeCZ simulators are published as labs within the REP and assign them to the exercise itinerary.

## NG-SOC
1. **Activate alert reception** from NG-SIEM by enabling the secure `soc-siem` channel.
2. **Synchronise CACAO playbooks** with NG-SOAR via the `soar-repository/sync` API to ensure validated versions are available.
3. **Expose the operational dashboard** by linking the playbook library as a knowledge source for real-time queries.

## NG-SIEM
1. **Select telemetry sources** associated with the lab and confirm that event classification matches the Subcase 1d scenarios.
2. **Publish correlation rules** that raise prioritised alerts towards NG-SOC.
3. **Enable exchange with CTI-SS** to enrich incidents automatically with current threat intelligence.

## NG-SOAR
1. **Import CACAO playbooks** received from NG-SOC and verify their integrity in the internal repository.
2. **Configure connectors** to CICMS Operator, CTI-SS and the playbook library, ensuring service credentials and certificates are up to date.
3. **Define execution queues** to separate automated tasks from those requiring manual intervention supervised by the CICMS Operator.

## CICMS Operator
1. **Register support processes** linked to the CACAO playbooks (approvals, reviews, field tasks) within the operational flow.
2. **Set SLAs and notifications** for each manual activity, routing alerts to the NG-SOC operational groups.
3. **Synchronise the tracking dashboard** with NG-SOAR to receive execution milestones and return closure confirmations.

## CTI-SS
1. **Select relevant intelligence sources** for the exercise and update the indicator feeds.
2. **Publish taxonomies and tags** that NG-SOAR will use to classify indicators during enrichment.
3. **Synchronise knowledge with the playbook library** so lessons learnt include up-to-date threat context.

## Playbook/standards library
1. **Define the knowledge space** for Subcase 1d, incorporating applicable MITRE ATT&CK, NVD and NIST references.
2. **Configure integrations** to receive data from NG-SOC, NG-SOAR and CICMS Operator through authenticated connectors.
3. **Enable automatic versioning** of documents to preserve the evolution of playbooks and procedures.

## Final validation
- Check from NG-SOC that all components respond to connectivity tests.
- Run a CACAO verification playbook and confirm that CICMS Operator, CTI-SS and the playbook library record activity.
- Document the results in CICMS Operator and notify the exercise owners.
