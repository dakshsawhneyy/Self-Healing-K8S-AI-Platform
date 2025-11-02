### MonoRepo Structure

self-healing-platform/
│
├── infrastructure/                  # Terraform code for EKS, IAM, S3/DynamoDB
├── kubernetes-manifests/                    # Kubernetes manifests (Helm charts, manifests)
├── services/               # Webhook remediator + AI analyzer code
├── observability/          # Prometheus, Grafana, Loki, Tempo configs
├── workflows/              # Argo Workflows YAMLs (for remediation)
├── chaos/                  # Chaos Mesh / LitmusChaos experiments
├── docs/                   # Architecture diagrams, notes, postmortems
└── README.md               # Project overview, commands, goals

