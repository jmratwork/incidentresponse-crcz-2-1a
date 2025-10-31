# Subcase 1a – Phishing Awareness on the Random Education Platform

This guide describes the activities carried out by the instructor and trainees within the Random Education Platform (REP) for the phishing awareness module. The flow mirrors the components documented in the CyberRangeCZ architecture.

## Course preparation by the instructor
- **Planning in the instructor console**: define the module objectives and assign the necessary resources from the CyberRangeCZ content repository.
- **Scheduling in REP Scheduler**: the instructor creates the themed course and enables the theory blocks, guided exercises and practical work on suspicious email analysis.
- **Synchronisation with the Reporting Workspace**: configure the metric dashboards that will receive the quiz and lab results.

## Session delivery
1. **Opening in REP Live Session**
   - The instructor starts the live session, shares the exercise rules and enables the integrated collaborative channels (chat, videoconferencing and whiteboard).
   - The trainees' workstations receive a personalised itinerary with theory capsules and reminders of good practice.
2. **Quizzes in REP Quiz Engine**
   - Each trainee answers formative quizzes that assess key phishing concepts.
   - The analytics panel displays scores in real time to guide the instructor's intervention.
3. **Email analysis lab**
   - Through the CyberRangeCZ simulators, trainees classify potentially malicious emails, verify headers and inspect attachments in a controlled environment.
   - The actions are recorded and linked to the course objectives for later assessment.
4. **Closure and reporting**
   - REP Practical Labs consolidates the lab results and sends an automatic summary to the Reporting Workspace.
   - The instructor reviews the findings and leads group feedback, highlighting strengths and improvement areas.

## Advanced exercises

### Multi-channel spear phishing campaign
- **Objective**: design and run a campaign combining email, instant messaging and simulated calls to reinforce the detection of targeted spear phishing tactics.
- **Key steps**:
  1. In **REP Scheduler**, the instructor programmes an additional block that synchronises the different channels and defines activation criteria for each trainee group.
  2. During the activity in **REP Live Session**, messages are released according to the planned timeline and participants' responses across collaborative channels are monitored.
  3. The outcomes are documented in **REP Practical Labs**, which records evidence for each channel and enables comparison of the effectiveness of the applied countermeasures.
  4. The **Reporting Workspace** consolidates indicators for each channel (click rate, suspicious responses, reporting times) to support the final debrief.

### Collaborative response chain
- **Objective**: train the coordination between technical and non-technical roles when a phishing alert is escalated on the platform.
- **Key steps**:
  1. The instructor enables in **REP Scheduler** a sequential exercise that assigns tasks to each role (analyst, communications lead, legal support) and defines escalation triggers.
  2. In **REP Live Session**, trainees work in real time on the case, using shared dashboards and chat to agree decisions and document actions.
  3. **REP Practical Labs** captures the generated artefacts (notification forms, support tickets, evidence analysis) and checks compliance with the playbook steps.
  4. The **Reporting Workspace** produces a collaboration report highlighting milestones, response times and critical dependencies.

### Express forensic report
- **Objective**: produce a concise forensic report after detecting a successful phishing attempt, summarising evidence and recommendations.
- **Key steps**:
  1. Via **REP Scheduler**, an intensive module is deployed including captured evidence, logs and compromised artefacts for review.
  2. In **REP Live Session**, the instructor leads a brief review of the critical evidence and clarifies the scope of the report to be delivered.
  3. Trainees use **REP Practical Labs** to process the evidence, generate preliminary findings and structure the report sections.
  4. The final report is uploaded to the **Reporting Workspace**, where it is validated against an incident response template and the conclusions are compared across teams.

## Assessment criteria
- Complete configuration of the course in REP Scheduler with all mandatory materials.
- Quiz pass rate above the threshold defined by the instructor.
- Lab coverage: header review, indicator analysis and attachment inspection within the simulators.
- Successful delivery of the advanced exercises, demonstrating multi-channel coordination, cross-role collaboration and forensic synthesis according to the Reporting Workspace guidelines.
- Submission of a final report summarising detected risks, findings from the advanced exercises and recommendations to mitigate phishing campaigns.

## Automatic platform feedback
- REP Quiz Engine immediately shows correct and incorrect answers, including the explanation associated with each question.
- REP Practical Labs awards partial scores for every email analysis step (identifying the sender, validating links and reviewing attachments) and raises alerts when evidence has not been documented.
- The Reporting Workspace issues a summary dashboard with compliance indicators and a traffic-light risk status per participant, providing a basis for the instructor's personalised feedback.
- For the advanced exercises, REP Scheduler generates alerts about incomplete milestones, REP Live Session offers records of collaborative participation, and the Reporting Workspace adds dedicated panels that display response times, the quality of forensic deliverables and the effectiveness of the multi-channel campaign.
