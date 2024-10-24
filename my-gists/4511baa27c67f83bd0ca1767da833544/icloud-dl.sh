#!/bin/bash
# given "https://www.icloud.com/iclouddrive/<ID>#<Filename>
ID="...."
URL=$(curl 'https://ckdatabasews.icloud.com/database/1/com.apple.cloudkit/production/public/records/resolve' \
  --data-raw '{"shortGUIDs":[{"value":"$ID"}]}' --compressed \
  jq -r '.results[0].rootRecord.fields.fileContent.value.downloadURL')
curl "$URL" -o myfile.ext