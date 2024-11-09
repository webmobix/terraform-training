# Infrastructure as Code with Terraform on Azure

## Preparation of the Azure environment

Login to Azure by in a terminal.

```shell
az login
```

Inside the `Prepare` folder update the `subscription_id` in `setup.tf`.
You can get the current subscription with this `az` command.

```shell
az account subscription list
```
Then plan and execute the Terraform plan.

```shell
terraform plan -out out.plan
terraform apply out.plan
```

To see the hidden password show the output as JSON.

```shell
terraform output --json
```

Copy hte displayed values for `client_id`, `tenant_id`, `subscription_id` into the `Training/main.tf` file and also update it for all students.

The password will be needed later on all student devices as well.


## Preparation of student devices

- install Terraform [https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- bookmark the documentatation website for the task
- check out the code repo and update the variables in `Training/main.tf`

Open Powershell and set the provided client secret.

```powershell
$env:TF_VAR_client_secret=
```

For Bash, set it like this.

```shell
export TF_VAR_client_secret=
```

## Presenter preparation

- check out the code repo
- install the dependencies for the presentation using `npm i`
- run the presentation like `npm start -- --port=8001`

## Presentation

Open the presentation at [http://localhost:8001](http://localhost:8001)

Use `S` to open the speaker notes and `F` for full screen.

## Hands On

### Update the deployed container to version `v2`.

### Add a new environment variable

https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app#env

## Solution

```hcl
resource "azurerm_container_app" "hello-world-app" {
  name                         = "hello-world-app-${random_integer.ri.result}"
  container_app_environment_id = data.azurerm_container_app_environment.app_env.id
  resource_group_name          = data.azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "hello-world"
      image  = "docker.io/dannyt74/hello-express:v2"
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name = "SECRET_CODE"
        value = "secret"
      }
    }
  }

  ingress {
    target_port = 3000
    external_enabled = true
    traffic_weight {
      latest_revision = true
      percentage = 100
    }
  }
}
```