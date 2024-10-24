#!/bin/bash

set -e

TRIGGER_ID=$(gcloud alpha builds triggers list \
	--filter='triggerTemplate.repoName:github_irio_wohnung' \
	--format json | jq --raw-output '.[0].id')

gcloud alpha builds triggers run $TRIGGER_ID \
	--branch master > /dev/null
