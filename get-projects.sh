#!/bin/bash

JIRA_URL="https://srowe74.atlassian.net"
EMAIL="stephen.rowe@srowe74.atlassian.net"
API_TOKEN="ATATT3xFfGF0aQ51dHQiTJk5YQeRLLW44JG5Xk8GfgzRiLW5SRwD6eJPa77LJ1UuGXPPyDlWJbVxPH66LSPq9BKHgk4xhXnv63dJYQZQtzRBb2o74j1U8-VPFk9Qu03qVufjGME1iWxjM-p0E65YAE1vLwQTTb5__fTx6VFjN3x8l64tH9UgfVA=38E35C42"

AUTH=$(echo -n "$EMAIL:$API_TOKEN" | base64)

curl -s -X GET \
    -H "Authorization: Basic $AUTH" \
    -H "Content-Type: application/json" \
    "$JIRA_URL/rest/api/3/project"
