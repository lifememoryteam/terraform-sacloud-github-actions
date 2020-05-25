FROM akiranet24/terraform-sakuracloud:latest

LABEL "com.github.actions.name"="terraform fmt"
LABEL "com.github.actions.description"="Validate terraform files are formatted"
LABEL "com.github.actions.icon"="terminal"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="https://github.com/ak1ra24/terraform-sacloud-github-actions"
LABEL "maintainer"="Shogo Maeda <ak1ra24net@gmail.com>"

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
