{{/*
Expand the name of the chart.
*/}}
{{- define "issuer-backend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "issuer-backend.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "issuer-backend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "issuer-backend.labels" -}}
helm.sh/chart: {{ include "issuer-backend.chart" . }}
{{ include "issuer-backend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "issuer-backend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "issuer-backend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "issuer-backend.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "issuer-backend.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Support for existing secrets
*/}}
{{- define "issuer-backend.secretFileName" -}}
    {{- if .Values.app.db.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.db.existingSecret.name $) -}}
    {{- else if .Values.app.security.serviceIdentity.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.security.serviceIdentity.existingSecret.name $) -}}
    {{- else if .Values.app.security.keycloak.client.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.security.keycloak.client.existingSecret.name $) -}}
    {{- else if .Values.app.mail.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.mail.existingSecret.name $) -}}
    {{- else if .Values.app.remoteSignature.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.remoteSignature.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "issuer-backend-secret" -}}
    {{- end -}}
{{- end -}}

{{/*
Database
*/}}
{{- define "issuer-backend.postgresPasswordKey" -}}
    {{- if .Values.app.db.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.db.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "password" -}}
    {{- end -}}
{{- end -}}

{{/*
Secutiry - Server Identity
*/}}
{{- define "issuer-backend.issuerIdentityPrivateKey" -}}
    {{- if .Values.app.security.serviceIdentity.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.security.serviceIdentity.existingSecret.privateKey $) -}}
    {{- else -}}
        {{- printf "private-key" -}}
    {{- end -}}
{{- end -}}

{{- define "issuer-backend.issuerIdentityDidKey" -}}
    {{- if .Values.app.security.serviceIdentity.existingSecret.enabled -}}
        {{- if .Values.app.security.serviceIdentity.existingSecret.didKey -}}
            {{- printf "%s" (tpl .Values.app.security.serviceIdentity.existingSecret.didKey $) -}}
        {{- else -}}
            {{- fail "issuerIdentityDidKey is missing or empty in the secret configuration" -}}
        {{- end -}}
    {{- else if .Values.app.security.serviceIdentity.didKey -}}
        {{- printf "%s" (tpl .Values.app.security.serviceIdentity.didKey $) -}}
    {{- else -}}
        {{- fail "issuerIdentityDidKey is missing in values.yaml" -}}
    {{- end -}}
{{- end -}}

{{- define "issuer-backend.issuerIdentityVC" -}}
    {{- if .Values.app.security.serviceIdentity.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.security.serviceIdentity.existingSecret.verifiableCredential $) -}}
    {{- else -}}
        {{- printf "vc" -}}
    {{- end -}}
{{- end -}}

{{/*
Secutiry - Keycloak
*/}}
{{- define "issuer-backend.keycloakClientSecretKey" -}}
    {{- if .Values.app.security.keycloak.client.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.security.keycloak.client.existingSecret.clientSecretKey $) -}}
    {{- else -}}
        {{- printf "client-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "issuer-backend.keycloakUserPasswordKey" -}}
    {{- if .Values.app.security.keycloak.client.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.security.keycloak.client.existingSecret.clientPasswordKey $) -}}
    {{- else -}}
        {{- printf "password" -}}
    {{- end -}}
{{- end -}}

{{/*
Email
*/}}
{{- define "issuer-backend.mailUsernameKey" -}}
    {{- if .Values.app.mail.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.mail.existingSecret.userKey $) -}}
    {{- else -}}
        {{- printf "username" -}}
    {{- end -}}
{{- end -}}

{{- define "issuer-backend.mailPasswordKey" -}}
    {{- if .Values.app.mail.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.mail.existingSecret.passwordKey $) -}}
    {{- else -}}
        {{- printf "password" -}}
    {{- end -}}
{{- end -}}

{{/*
Remote Signature
*/}}
{{- define "issuer-backend.remote-signature.clientId" -}}
    {{- if .Values.app.remoteSignature.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.remoteSignature.existingSecret.clientId $) -}}
    {{- else -}}
        {{- printf "client-id" -}}
    {{- end -}}
{{- end -}}

{{- define "issuer-backend.remote-signature.clientSecret" -}}
    {{- if .Values.app.remoteSignature.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.remoteSignature.existingSecret.clientSecret $) -}}
    {{- else -}}
        {{- printf "client-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "issuer-backend.remote-signature.credentialId" -}}
    {{- if .Values.app.remoteSignature.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.remoteSignature.existingSecret.credentialId $) -}}
    {{- else -}}
        {{- printf "credential-id" -}}
    {{- end -}}
{{- end -}}

{{- define "issuer-backend.remote-signature.credentialPassword" -}}
    {{- if .Values.app.remoteSignature.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.remoteSignature.existingSecret.credentialPassword $) -}}
    {{- else -}}
        {{- printf "credential-password" -}}
    {{- end -}}
{{- end -}}

{{/*
Signer data --> fixme: depecrated and should be removed
*/}}
{{- define "issuer-backend.signerCommonName" -}}
    {{- if .Values.app.remoteSignature.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.remoteSignature.defaultSigner.existingSecret.commonName $) -}}
    {{- else -}}
        {{- printf "common-name" -}}
    {{- end -}}
{{- end -}}

{{- define "issuer-backend.signerSerialNumber" -}}
    {{- if .Values.app.remoteSignature.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.remoteSignature.defaultSigner.existingSecret.serialNumber $) -}}
    {{- else -}}
        {{- printf "serial-number" -}}
    {{- end -}}
{{- end -}}

{{- define "issuer-backend.signerEmail" -}}
    {{- if .Values.app.remoteSignature.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.remoteSignature.defaultSigner.existingSecret.email $) -}}
    {{- else -}}
        {{- printf "email" -}}
    {{- end -}}
{{- end -}}

{{- define "issuer-backend.signerOrganization" -}}
    {{- if .Values.app.remoteSignature.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.remoteSignature.defaultSigner.existingSecret.organization $) -}}
    {{- else -}}
        {{- printf "organization" -}}
    {{- end -}}
{{- end -}}

{{- define "issuer-backend.signerOrganizationIdentifier" -}}
    {{- if .Values.app.remoteSignature.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.remoteSignature.defaultSigner.existingSecret.organizationIdentifier $) -}}
    {{- else -}}
        {{- printf "organization-identifier" -}}
    {{- end -}}
{{- end -}}

{{- define "issuer-backend.signerCountry" -}}
    {{- if .Values.app.remoteSignature.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.remoteSignature.defaultSigner.existingSecret.country $) -}}
    {{- else -}}
        {{- printf "country" -}}
    {{- end -}}
{{- end -}}

{{/*
Internal Server Port
*/}}
{{- define "issuer-backend.serverPort" -}}
{{- default 8080 }}
{{- end }}

{{/*
Issuer API External Domain
*/}}
{{- define "issuer.externalDomain" -}}
{{- if eq .Values.global.environment "prod" -}}
    issuer.{{ .Values.global.tenantName }}.{{ .Values.global.externalDomain }}
{{- else -}}
    issuer-{{ .Values.global.environment }}.{{ .Values.global.tenantName }}.{{ .Values.global.externalDomain }}
{{- end }}
{{- end }}

{{/*
Keycloak External Domain
*/}}
{{- define "issuer-backend.keycloakExternalDomain" -}}
{{- if eq .Values.global.environment "prod" -}}
    keycloak.{{ .Values.global.externalDomain }}
{{- else -}}
    keycloak-{{ .Values.global.environment }}.{{ .Values.global.externalDomain }}
{{- end }}
{{- end }}
