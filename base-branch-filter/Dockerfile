FROM alpine:latest

LABEL "com.github.actions.name"="base branch filter"
LABEL "com.github.actions.description"="Filters pull request events based on their base branch."
LABEL "com.github.actions.icon"="filter"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="https://github.com/ak1ra24/terraform-sacloud-github-actions"
LABEL "maintainer"="Shogo Maeda <ak1ra24net@gmail.com>"

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
