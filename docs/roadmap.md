# Self‑Healing Kubernetes Platform with AI‑Assisted Remediation

**Owner:** Daksh
**Goal:** Build a production‑grade EKS‑based platform that detects incidents via observability, automatically executes remediation workflows, and uses an AI assistant to analyze and summarize root causes. This showcases SRE automation, observability, incident response, and optional AI-assisted analysis.

---

## 1) High‑level: Why this project?

- **SRE‑first**: It covers SLIs/SLOs, error budgets, golden signals, and automated incident handling — the core of SRE interviews.
- **End‑to‑end ownership**: You’ll touch infra (Terraform), cluster ops (EKS), CI/CD, observability, automation orchestration, and incident storage/forensics.
- **Highly demonstrable**: Run chaos experiments to show self‑healing in action, and produce measurable before/after results for a resume/portfolio demo.
- **Modular & extensible**: Start small (alerts → simple autoscale), then add workflows, policies, and finally AI analysis (Claude/OpenAI).
- **MAANG relevance**: Demonstrates production thinking recruiters at top companies look for: reliability automation, monitoring, and incident playbooks.

---

## 2) Architecture (text diagram)

```
Users --> ALB/Ingress --> App (K8s services)
                      |
                      v
                 Prometheus <-- kube-state-metrics / node-exporter
                 Loki (logs)  <-- app logs (fluent-bit)
                 Tempo (traces)
                      |
                      v
                 Alertmanager -> Webhook -> Remediation Service
                                      |             |
                                      v             v
                                 Argo Workflows   Lambda / API
                                      |             |
                                      v             v
                                K8s remediate   eksctl/kubectl actions
                                      |
                                      v
                                Incident DB (DynamoDB / S3)
                                      |
                                      v
                                AI Analysis (Claude/OpenAI)
                                      |
                                      v
                                  Slack / Grafana / Backstage plugin
```

> Notes: Use Terraform to provision EKS, VPCs, ALB, IAM, and DynamoDB/S3. Use Argo Workflows or Argo Events for stateful remediation orchestration. Implement a small webhook service (Node.js/Python/Go) that receives Alertmanager hooks and decides remediation steps.

---

## 3) Phase‑by‑Phase Roadmap 

### Phase 0 — Prep 
- Setup GitHub repo (monorepo with `infra/`, `k8s/`, `services/`, `observability/`) and issue tracker.  
- Decide tech choices (Terraform, EKS, Argo, Prometheus, Loki, Grafana, Alertmanager, Argo Workflows, language for webhook service).  
- Create an initial `README.md` with scope and success metrics.

### Phase 1 — Foundation & Observability 
**Goal:** Working EKS cluster + sample app + end‑to‑end metrics/logs/traces.

**Deliverables**:
- Terraform code to provision EKS, VPC, IAM roles, and an S3/DynamoDB bucket.  
- Deploy sample 3‑tier app (frontend, backend, database stub) to the cluster.  
- Setup Prometheus (kube‑prometheus or Prometheus Operator), Grafana, Loki, and Tempo.  
- Instrument app for metrics (Prometheus client), structured logs (stdout JSON), and basic traces (OpenTelemetry SDK).

**Learning Objectives**:
- Understand Terraform modules, state, and workspaces.  
- Configure Prometheus scraping, serviceMonitors, and basic PromQL queries.  
- Use Loki for log queries and Tempo for trace correlation.  

**Success Check**: Able to query a 95th percentile latency metric and see logs related to that request in Loki.

---

### Phase 2 — Alerting + Basic Remediation 
**Goal:** Alerts fire and trigger a basic remediation action.

**Deliverables**:
- Define SLIs/SLOs (latency, error rate, availability) and create Alertmanager rules.  
- Create Alertmanager webhook configuration pointed at a `remediator` service.  
- Implement a minimal `remediator` (Node.js/Express or Python/Flask) that receives alerts and runs remediation commands via `kubectl` (invoked through Kubernetes API client) or triggers a Job/Argo Workflow.
- Add Slack notifications showing remediation steps.

**Learning Objectives**:
- Compose Alertmanager routing and silences.  
- Remediation via Kubernetes API (scale down/up, restart pods, cordon/drain).  

**Success Check**: Simulate high CPU → Alert triggers → Remediator restarts pods or scales deployment and posts Slack message.

---

### Phase 3 — Orchestrated Remediation Workflows 
**Goal:** Replace ad‑hoc calls with structured workflows and incident logging.

**Deliverables**:
- Install Argo Workflows (or use AWS Step Functions/AWS Lambda orchestration).  
- Design YAML workflows for common incidents: `restart-pods`, `scale-services`, `rollout-rollback`, `evict-node`.  
- Integrate workflows with the `remediator` so alerts trigger workflows with contextual metadata.  
- Persist incident metadata and remediation actions to DynamoDB or S3 for auditing.

**Learning Objectives**:
- Authoring and triggering Argo Workflows.  
- Passing parameters to workflows from Alertmanager.  
- Durable incident records for post‑mortem.

**Success Check**: Alert triggers Argo Workflow that runs a multi‑step remediation (e.g., scale down, run health check, scale up) and logs steps.

---

### Phase 4 — Observability Improvements & SLOs 
**Goal:** Tighten observability, add dashboards, and measure SLO compliance.

**Deliverables**:
- Grafana dashboards for golden signals and per‑service SLO visualization.  
- Alert rules based on error budgets and burn rate.  
- Automated test harness (k6 or Locust) to generate load for demonstration.

**Learning Objectives**:
- Implement error budget alerts and burn rate analysis.  
- Use synthetic tests to validate the remediation system.

**Success Check**: Under load test, system breaches SLO → automated remediation kicks in → dashboard shows error budget reduction and recovery.

---

### Phase 5 — Chaos + Validation 
**Goal:** Verify self‑healing using chaos experiments and validate runbooks.

**Deliverables**:
- Integrate Chaos Mesh or LitmusChaos and create experiments (kill pod, network delay, CPU hog).  
- Run experiments and capture remediation logs, traces, and timeline.  
- Write short postmortem reports (incidents captured automatically in Incident DB).

**Learning Objectives**:
- Design chaos experiments safely.  
- Correlate chaos events with graphs, logs, and remediation actions.

**Success Check**: Chaos event triggers remediation workflow and system recovers within SLO target.

---

### Phase 6 — AI‑Assisted Analysis & UX 
**Goal:** Add AI analysis to make remediation explanations human‑friendly.

**Deliverables**:
- Implement an `analyzer` lambda/service that pulls logs/traces for the incident and sends summarized prompt to Claude/OpenAI.  
- Store AI summary in Incident DB and post to Slack with remediation steps and likelihood/outcome.  
- (Optional) Build a simple Backstage plugin or Grafana panel showing incidents with AI summaries.

**Learning Objectives**:
- Safely craft prompts to extract root cause hints from logs & traces.  
- Evaluate model outputs for accuracy and hallucination risk.  

**Success Check**: For a real incident, AI provides a useful summary (2–4 lines) and suggests next steps that a human engineer finds helpful.

---

## 4) Tech Stack & Reasoning

- **Infra:** Terraform (modules, workspaces), AWS (EKS, ALB, S3/DynamoDB, IAM) — reproducible infra is a must.
- **K8s tooling:** Helm for app charts, ArgoCD (optional) for GitOps, Argo Workflows for remediation orchestration.
- **Observability:** Prometheus (metrics) + Grafana (dashboards) + Loki (logs) + Tempo (traces) + OpenTelemetry in app.
- **Remediation Service:** Node.js or Python — use official Kubernetes client libs (client-go if Go) to avoid brittle shelling out.
- **Workflow Engine:** Argo Workflows (Kubernetes native) or AWS Step Functions if you want serverless orchestration.
- **Chaos:** LitmusChaos or Chaos Mesh.
- **AI (optional):** Claude or OpenAI for summarization — ensure privacy & log redaction.

---

## 5) Security, Permissions & Safety Notes
- Create least‑privilege IAM roles for automation workflows (only allow scale/restart actions on specific namespaces).  
- Redact sensitive data before sending logs/traces to AI models (secrets, PII).  
- Limit chaos experiments to non‑prod namespaces and implement kill switches.

---

## 6) Testing & Demo Plan
1. **Dry‑run locally** with k3s / kind to iterate fast.  
2. **Deploy to dev EKS** and run synthetic load tests with k6.  
3. **Run chaos scenarios** and capture remediation trace.  
4. **Record a 4–6 minute demo**: show alert → workflow → remediation → AI summary → dashboard postmortem.  

---

## 7) Deliverables for Resume / Portfolio
- GitHub repo with `infra/`, `k8s/`, `services/`, `observability/`, `workflows/`.  
- README with architecture diagram, deployment steps, and how to run demo.  
- Blog post (2 posts): (1) design & decisions, (2) demo + lessons learned + SLO metrics.  
- Short recorded demo video and 1‑page case study with results & lessons.

**Resume bullets** (examples):
- "Designed and implemented a self‑healing Kubernetes platform on AWS EKS using Prometheus, Grafana, Argo Workflows, and Terraform; automated incident remediation that reduced mean time to recovery (MTTR) by X% in synthetic tests."  
- "Built AI‑assisted incident summarizer (Claude/OpenAI) to provide concise root cause hints and remediation suggestions, integrated with Slack and incident DB."

---

## 8) Metrics to measure success
- **MTTR** before vs after automation (synthetic).  
- **Number of incidents auto‑remediated** vs manual.  
- **SLO attainment** over test window.  
- **False positive remediation rate** (avoid noisy automation).  

---

## 9) Risk Areas & Mitigations
- **Automation causing bad state**: implement a dry‑run mode and require human approval for risky actions.  
- **AI hallucinations**: use AI only for suggestions; never for automatic cluster changes.  
- **Permissions overreach**: use scoped roles & namespaces.  

---

## 10) Extensions & Follow‑ups (6–12 months)
- Integrate with Backstage as a plugin for incident insights & self‑service runbooks.  
- Add a policy engine (OPA/Gatekeeper) to prevent dangerous infra changes.  
- Build MCP/Checkov auto‑fix module to suggest Terraform fixes (your other idea).  
- Convert remediation actions into Kubernetes Operators (controller) for stateful management.

---

## 11) Week‑by‑Week Learning Objectives (compact)
- **Week 0 (2–4 days):** Repo + infra decisions + local kind experiments.  
- **Week 1:** Terraform EKS + sample app + Prometheus/Loki/Tempo + basic dashboards.  
- **Week 2:** Alerts + remediator service + Slack notifications.  
- **Week 3:** Argo Workflows + incident DB + structured remediation.  
- **Week 4:** SLOs, dashboards, synthetic tests and metrics collection.  
- **Week 5:** Chaos experiments and validation.  
- **Week 6:** AI analyzer integration + Backstage/Grafana UX polish + demo prep.

---

## 12) Checklist (preflight & launch)
- [ ] Git repo created + CI pipeline for infra/app.  
- [ ] Terraform modules and state backend (S3 + DynamoDB locking).  
- [ ] EKS cluster accessible and `kubectl` configured.  
- [ ] Observability stack deployed and scraping running.  
- [ ] Alertmanager webhook + remediator service working.  
- [ ] Argo Workflows installed and test workflows created.  
- [ ] Incident DB receiving events.  
- [ ] Chaos experiments implemented in dev namespace.  
- [ ] AI integration with redaction in place (if used).  
- [ ] Demo video recorded and blog draft ready.

---

## 13) Quick Starter Commands & Snippets
- Terraform bootstrap (example):
```bash
cd infra
terraform init
terraform workspace new dev || terraform workspace select dev
terraform apply -var-file=dev.tfvars
```
- Kind local quick test (optional):
```bash
kind create cluster --config kind-config.yaml
kubectl apply -f k8s/sample-app.yaml
```
- Send a synthetic alert (simulate):
```bash
curl -XPOST http://<remediator>/alert -d '{"status":"firing","labels":{"alertname":"HighCPU"}}'
```

---

<!-- ## 14) Final Notes — storytelling & interview prep
- Keep **metrics** and **before/after numbers** front and center for interviews.  
- Prepare a 3‑slide summary: (1) problem, (2) architecture & automation, (3) results & lessons.  
- Expect deep questions on alert fatigue, false positives, permissioning, and safety checks — have design tradeoffs documented.

--- -->