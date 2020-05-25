#!/bin/sh

# wrap takes some output and wraps it in a collapsible markdown section if
# it's over $TF_ACTION_WRAP_LINES long.
wrap() {
  if [[ $(echo "$1" | wc -l) -gt ${TF_ACTION_WRAP_LINES:-20} ]]; then
    echo "
<details><summary>Show Output</summary>

\`\`\`
$1
\`\`\`

</details>
"
else
    echo "
\`\`\`
$1
\`\`\`
"
fi
}

set -e

if [ -z "$TF_SACLOUD_PROVIDER_VERSION" ]; then
	TF_SACLOUD_PROVIDER_VERSION=$(curl -s https://api.github.com/repos/sacloud/terraform-provider-sakuracloud/releases | jq -r '.[0] | .tag_name' | sed -e 's/[^0-9\.]//g')
fi

echo "$TF_SACLOUD_PROVIDER_VERSION download..."
wget https://github.com/sacloud/terraform-provider-sakuracloud/releases/download/v${TF_SACLOUD_PROVIDER_VERSION}/terraform-provider-sakuracloud_${TF_SACLOUD_PROVIDER_VERSION}_linux-amd64.zip
unzip terraform-provider-sakuracloud_${TF_SACLOUD_PROVIDER_VERSION}_linux-amd64.zip
rm terraform-provider-sakuracloud_${TF_SACLOUD_PROVIDER_VERSION}_linux-amd64.zip
rm -rf /terraform-provider-sakuracloud
mv terraform-provider-sakuracloud* /terraform-provider-sakuracloud

cd "${TF_ACTION_WORKING_DIR:-.}"

if [[ ! -z "$TF_ACTION_TFE_TOKEN" ]]; then
  cat > ~/.terraformrc << EOF
credentials "${TF_ACTION_TFE_HOSTNAME:-app.terraform.io}" {
  token = "$TF_ACTION_TFE_TOKEN"
}
EOF
fi

if [[ ! -z "$TF_ACTION_WORKSPACE" ]] && [[ "$TF_ACTION_WORKSPACE" != "default" ]]; then
  terraform workspace select "$TF_ACTION_WORKSPACE"
fi

set +e
PLUGINS_DIR="$HOME/.terraform.d/plugins/linux_amd64"
mkdir -p $PLUGINS_DIR
cp -f /terraform-provider-sakuracloud $PLUGINS_DIR
set -e

set +e
OUTPUT=$(sh -c "TF_IN_AUTOMATION=true terraform apply -no-color -auto-approve -input=false $*" 2>&1)
SUCCESS=$?
echo "$OUTPUT"
set -e

# If PR_DATA is null, then this is not a pull request event and so there's
# no where to comment.
PR_DATA=$(cat /github/workflow/event.json | jq -r .pull_request)
if [ "$TF_ACTION_COMMENT" = "1" ] || [ "$TF_ACTION_COMMENT" = "false" ] || [ "$PR_DATA" = "null" ]; then
    exit $SUCCESS
fi

# Build the comment we'll post to the PR.
COMMENT=""
if [ $SUCCESS -ne 0 ]; then
    OUTPUT=$(wrap "$OUTPUT")
    COMMENT="#### \`terraform apply\` Failed
$OUTPUT

*Workflow: \`$GITHUB_WORKFLOW\`, Action: \`$GITHUB_ACTION\`*"
else
    # Call wrap to optionally wrap our output in a collapsible markdown section.
    OUTPUT=$(wrap "$OUTPUT")
    COMMENT="#### \`terraform apply\` Success
$OUTPUT

*Workflow: \`$GITHUB_WORKFLOW\`, Action: \`$GITHUB_ACTION\`*"
fi

# Post the comment.
PAYLOAD=$(echo '{}' | jq --arg body "$COMMENT" '.body = $body')
COMMENTS_URL=$(cat /github/workflow/event.json | jq -r .pull_request.comments_url)
curl -s -S -H "Authorization: token $GITHUB_TOKEN" --header "Content-Type: application/json" --data "$PAYLOAD" "$COMMENTS_URL" > /dev/null

exit $SUCCESS
