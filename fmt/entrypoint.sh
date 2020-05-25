#!/bin/sh
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

set +e
OUTPUT=$(sh -c "terraform fmt -no-color -check -list -recursive $*" 2>&1)
SUCCESS=$?
echo "$OUTPUT"
set -e

if [ $SUCCESS -eq 0 ]; then
    exit 0
fi

if [ "$TF_ACTION_COMMENT" = "1" ] || [ "$TF_ACTION_COMMENT" = "false" ]; then
    exit $SUCCESS
fi

if [ $SUCCESS -eq 2 ]; then
    # If it exits with 2, then there was a parse error and the command won't have
    # printed out the files that have failed. In this case we comment back with the
    # whole parse error.
    COMMENT="\`\`\`
$OUTPUT
\`\`\`
"
else
    # Otherwise the output will contain a list of unformatted filenames.
    # Iterate through each file and build up a comment containing the diff
    # of each file.
    COMMENT=""
    for file in $OUTPUT; do
        FILE_DIFF=$(terraform fmt -no-color -write=false -diff "$file" | sed -n '/@@.*/,//{/@@.*/d;p}')
        COMMENT="$COMMENT
<details><summary><code>$file</code></summary>

\`\`\`diff
$FILE_DIFF
\`\`\`
</details>
"
    done
fi

COMMENT_WRAPPER="#### \`terraform fmt\` Failed
$COMMENT
*Workflow: \`$GITHUB_WORKFLOW\`, Action: \`$GITHUB_ACTION\`*
"
PAYLOAD=$(echo '{}' | jq --arg body "$COMMENT_WRAPPER" '.body = $body')
COMMENTS_URL=$(cat /github/workflow/event.json | jq -r .pull_request.comments_url)
curl -s -S -H "Authorization: token $GITHUB_TOKEN" --header "Content-Type: application/json" --data "$PAYLOAD" "$COMMENTS_URL" > /dev/null

exit $SUCCESS
