# GCP Compute Engine with Managed Instance Group (MIG) - Oracle Linux

This Terraform repository creates 5 GCP compute instances running Oracle Linux 8 using a Managed Instance Group (MIG).

## Features

- **Managed Instance Group (MIG)** with 5 Oracle Linux instances
- **Custom VPC Network** with subnet
- **Firewall Rules** for SSH and HTTP/HTTPS access
- **Auto-healing** with health checks
- **Optional Autoscaling** support
- **Instance Templates** for easy scaling and updates

## Prerequisites

1. **Google Cloud Platform Account** with a project created
2. **Terraform** installed (v1.0 or later)
3. **Google Cloud SDK (gcloud)** installed and configured
4. **Appropriate GCP permissions** to create:
   - Compute instances
   - VPC networks and subnets
   - Firewall rules
   - Instance templates and groups

## GCP Authentication

Authenticate with GCP using one of these methods:

```bash
# Method 1: Application Default Credentials
gcloud auth application-default login

# Method 2: Service Account (recommended for production)
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
```

## Setup Instructions

### 1. Clone or Download the Repository

```bash
git clone <repository-url>
cd Google-Compute-engine-with-MIG-TF
```

### 2. Configure Variables

Copy the example tfvars file and customize it:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and update the following required variables:

```hcl
project_id = "your-gcp-project-id"  # REQUIRED: Your GCP project ID
region     = "us-central1"           # Optional: Change if needed
zone       = "us-central1-a"         # Optional: Change if needed
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review the Execution Plan

```bash
terraform plan
```

### 5. Deploy the Infrastructure

```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

## Configuration Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `project_id` | GCP Project ID | - | Yes |
| `region` | GCP region | `us-central1` | No |
| `zone` | GCP zone | `us-central1-a` | No |
| `name_prefix` | Prefix for resource names | `oracle-linux` | No |
| `subnet_cidr` | Subnet CIDR range | `10.0.1.0/24` | No |
| `machine_type` | Instance machine type | `e2-medium` | No |
| `disk_size_gb` | Boot disk size in GB | `20` | No |
| `instance_count` | Number of instances | `5` | No |
| `ssh_keys` | SSH public keys | `""` | No |
| `startup_script` | Instance startup script | Basic script | No |
| `enable_autoscaling` | Enable autoscaling | `false` | No |
| `min_replicas` | Min instances for autoscaling | `3` | No |
| `max_replicas` | Max instances for autoscaling | `10` | No |

## Outputs

After successful deployment, Terraform will output:

- **network_name**: VPC network name
- **subnet_name**: Subnet name
- **instance_group_manager_name**: MIG name
- **instance_template_name**: Instance template name
- **instance_group_url**: Instance group URL
- **health_check_name**: Health check name
- **oracle_linux_image**: Oracle Linux image used

## Managing the Infrastructure

### View Instance Group Status

```bash
gcloud compute instance-groups managed describe oracle-linux-mig --zone=us-central1-a
```

### List Instances in the Group

```bash
gcloud compute instance-groups managed list-instances oracle-linux-mig --zone=us-central1-a
```

### SSH into an Instance

```bash
gcloud compute ssh oracle-linux-instance-<xxxx> --zone=us-central1-a
```

### Update the MIG (Rolling Update)

After modifying the instance template:

```bash
terraform apply
```

The MIG will automatically perform a rolling update.

### Enable Autoscaling

Set `enable_autoscaling = true` in your `terraform.tfvars` and run:

```bash
terraform apply
```

### Destroy the Infrastructure

```bash
terraform destroy
```

Type `yes` when prompted to confirm deletion.

## Architecture

```
┌─────────────────────────────────────────┐
│         VPC Network                     │
│  ┌───────────────────────────────────┐  │
│  │      Subnet (10.0.1.0/24)         │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │  Managed Instance Group     │  │  │
│  │  │  ┌─────────────────────┐    │  │  │
│  │  │  │ Oracle Linux VM 1   │    │  │  │
│  │  │  │ Oracle Linux VM 2   │    │  │  │
│  │  │  │ Oracle Linux VM 3   │    │  │  │
│  │  │  │ Oracle Linux VM 4   │    │  │  │
│  │  │  │ Oracle Linux VM 5   │    │  │  │
│  │  │  └─────────────────────┘    │  │  │
│  │  │  Health Check (TCP:22)      │  │  │
│  │  │  Auto-healing Enabled       │  │  │
│  │  └─────────────────────────────┘  │  │
│  └───────────────────────────────────┘  │
│  Firewall: SSH (22), HTTP (80, 443)    │
└─────────────────────────────────────────┘
```

## Cost Considerations

- **5 x e2-medium instances** running 24/7
- **Network egress charges** for internet traffic
- **Disk storage** (20GB per instance)

Estimate your costs using the [GCP Pricing Calculator](https://cloud.google.com/products/calculator).

## Troubleshooting

### Quota Issues

If you encounter quota errors:

```bash
gcloud compute project-info describe --project=your-project-id
```

Request quota increases in the GCP Console under IAM & Admin → Quotas.

### Health Check Failures

Check the health check status:

```bash
gcloud compute health-checks describe oracle-linux-healthcheck
```

### Instance Creation Failures

Check the MIG errors:

```bash
gcloud compute instance-groups managed describe oracle-linux-mig --zone=us-central1-a
```

## Security Recommendations

1. **Restrict SSH access**: Modify the firewall rule to allow only specific IP ranges
2. **Use service accounts**: Create dedicated service accounts with minimal permissions
3. **Enable OS Login**: Use GCP OS Login instead of metadata-based SSH keys
4. **Regular updates**: Keep Oracle Linux updated with security patches

## License

This Terraform configuration is provided as-is for educational and deployment purposes.

## Support

For issues related to:
- **Terraform**: [Terraform Documentation](https://www.terraform.io/docs)
- **GCP**: [Google Cloud Documentation](https://cloud.google.com/docs)
- **Oracle Linux**: [Oracle Linux Documentation](https://docs.oracle.com/en/operating-systems/oracle-linux/)
