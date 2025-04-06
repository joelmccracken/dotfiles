#!/usr/bin/env sh

env | sort

jq '.' <<-EOF
  $GITHUB_JSON_PAYLOAD
EOF
