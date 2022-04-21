# EKS Helm Deploy GitHub Action

This GitHub action uses AWS CLI to login to EKS and deploy a helm chart.

## Inputs
Input parameters allow you to specify data that the action expects to use during runtime.

- `aws-secret-access-key`: AWS secret access key part of the aws credentials. This is used to login to EKS. (required)
- `aws-access-key-id`: AWS access key id part of the aws credentials. This is used to login to EKS. (required)
- `aws-region`: AWS region to use. This must match the region your desired cluster lies in. (default: us-east2)
- `cluster-name`: The name of the desired cluster. (required)
- `cluster-role-arn`: If you wish to assume an admin role, provide the role arn here to login as. 
- `config-files`: Comma separated list of helm values files.
- `debug`: Enable verbose output.
- `dry-run`: Simulate an upgrade.
- `namespace`: Kubernetes namespace to use.
- `chart-path`: The path to the chart. (defaults to `helm/`)

## Example usage

```yaml
uses: ar-rehman135/eks-helm-deploy-ic@master
with:
  aws-access-key-id: ${{ secrets.events.input.AWS_ACCESS__KEY_ID }}
  aws-secret-access-key: ${{ secrets.events.input.AWS_SECRET_ACCESS_KEY }}
  aws-region: us-east-2
  cluster-name: ic-b4d-aws-ps-east-2
  config-files: ""
  namespace: ""
```
