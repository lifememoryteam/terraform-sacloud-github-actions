FROM akiranet24/terraform-sakuracloud:latest

LABEL "com.github.actions.name"="terraform apply"
LABEL "com.github.actions.description"="Run Terraform Apply"
LABEL "com.github.actions.icon"="play-circle"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="https://github.com/ak1ra24/terraform-sacloud-github-actions"
LABEL "maintainer"="Shogo Maeda <ak1ra24net@gmail.com>"

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
