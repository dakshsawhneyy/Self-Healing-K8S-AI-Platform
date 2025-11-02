### MonoRepo Structure

| Directory   | Description   |
|-------------- | -------------- |
| **infrastructure/** | Contains Terraform code for provisioning AWS EKS clusters, IAM roles, and state storage (S3/DynamoDB). |
| **kubernetes-manifests/** | Holds Helm charts and Kubernetes manifests for deploying platform components. |
| **services/** | Includes code for the self-healing logic — AI analyzer and webhook remediator. |
| **observability/** | Configuration for Prometheus, Grafana, Loki, and Tempo for monitoring and tracing. |
| **workflows/** | YAML definitions for **Argo Workflows** handling remediation pipelines. |
| **chaos/** | Contains chaos engineering experiments using **Chaos Mesh** or **LitmusChaos**. |
| **docs/** | Documentation resources — architecture diagrams, design notes, and postmortems. |
| **README.md** | Root documentation with setup instructions, goals, and commands. |

### Purpose
This monorepo centralizes all components of the **Self-Healing Kubernetes AI Platform** — integrating infrastructure as code, observability, chaos testing, and autonomous remediation through AI.