# terraform-sacloud-github-actions

## Options
* TF_ACTION_WORKING_DIR
	* Specify the directory to run terraform
* TF_SACLOUD_PROVIDER_VERSION
	* Specify the version of terraform-provider-sakuracloud

## Example
```
name: push
on:
  push:
    branches:
    - master
env:
  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  SAKURACLOUD_ACCESS_TOKEN: ${{ secrets.SAKURACLOUD_ACCESS_TOKEN }}
  SAKURACLOUD_ACCESS_TOKEN_SECRET: ${{ secrets.SAKURACLOUD_ACCESS_TOKEN_SECRET }}
  SAKURACLOUD_ZONE: ${{ secrets.SAKURACLOUD_ZONE }}
  TF_ACTION_WORKING_DIR: "terraform/production"
  TF_SACLOUD_PROVIDER_VERSION: "x.x.x"
jobs:
  terraform:
    name: 'Terraform'
    runs-on: ubuntu-latest
    steps:
      - name: 'Checkout'
        uses: actions/checkout@master
      - name: 'Terraform Format'
        uses: "lifememoryteam/terraform-sacloud-github-actions/fmt@master"
      - name: 'Terraform Init'
        uses: "lifememoryteam/terraform-sacloud-github-actions/init@master"
      - name: "Terraform Plan"
        uses: "lifememoryteam/terraform-sacloud-github-actions/plan@master"
      - name: "Terraform Apply"
        uses: "lifememoryteam/terraform-sacloud-github-actions/apply@master"

```
