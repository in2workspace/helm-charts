#!/bin/bash

# Define the path to the realm file
REALM_FILE="/opt/keycloak/data/import/CredentialIssuer-realm.json"
TEMP_FILE="/tmp/CredentialIssuer-realm.json"

# Ensure the original realm file is readable
if [[ -r $REALM_FILE ]]; then
  # Copy the realm file to a temporary writable location
  cp $REALM_FILE $TEMP_FILE

  # Function to update or add JSON values within smtpServer using sed and awk
  update_or_add_json_in_smtpServer() {
    local key=$1
    local value=$2
    if grep -q "\"$key\":" $TEMP_FILE; then
      # Update existing key
      sed -i "/\"smtpServer\": {/,/}/{s|\"$key\": \".*\"|\"$key\": \"$value\"|g}" $TEMP_FILE
    else
      # Add new key, ensure commas are handled correctly
      sed -i "/\"smtpServer\": {/a \ \ \ \ \"$key\": \"$value\"," $TEMP_FILE
    fi
  }

  # Update or add the JSON values within smtpServer
  update_or_add_json_in_smtpServer "host" "$SMTP_HOST"
  update_or_add_json_in_smtpServer "port" "$SMTP_PORT"
  update_or_add_json_in_smtpServer "user" "$SMTP_USER"
  update_or_add_json_in_smtpServer "password" "$SMTP_PASSWORD"
  update_or_add_json_in_smtpServer "from" "$SMTP_FROM"
  update_or_add_json_in_smtpServer "fromDisplayName" "$SMTP_FROM_DISPLAY_NAME"
  update_or_add_json_in_smtpServer "replyTo" "$SMTP_REPLY_TO"
  update_or_add_json_in_smtpServer "starttls" "$SMTP_STARTTLS"
  update_or_add_json_in_smtpServer "auth" "$SMTP_AUTH"
  update_or_add_json_in_smtpServer "ssl" "$SMTP_SSL"

  # Ensure proper JSON formatting by fixing missing commas
  # Add a comma after each key-value pair in smtpServer except the last one
  sed -i '/"smtpServer": {/,/}/{s/\(.*\)"/\1",/;s/,\([^,]*\)$/\1/}' $TEMP_FILE

  # Add a comma after the closing bracket of smtpServer if there is none
  sed -i '/"smtpServer": {/,/}/s/\(}\)/\1,/' $TEMP_FILE

  # Overwrite the original file with the modified content
  cat $TEMP_FILE > $REALM_FILE
else
  echo "Error: Cannot read $REALM_FILE. Please check the file permissions."
  exit 1
fi

# Start Keycloak with realm import
/opt/keycloak/bin/kc.sh import --file $REALM_FILE --override true

# Start Keycloak
exec /opt/keycloak/bin/kc.sh start-dev --health-enabled=true --metrics-enabled=true --log-level=INFO --import-realm
