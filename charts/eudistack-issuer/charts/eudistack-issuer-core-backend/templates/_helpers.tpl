{{/*
Expand the name of the chart.
*/}}
{{- define "eudistack-issuer-core-backend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "eudistack-issuer-core-backend.fullname" -}}
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
{{- define "eudistack-issuer-core-backend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "eudistack-issuer-core-backend.labels" -}}
helm.sh/chart: {{ include "eudistack-issuer-core-backend.chart" . }}
{{ include "eudistack-issuer-core-backend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "eudistack-issuer-core-backend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "eudistack-issuer-core-backend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "eudistack-issuer-core-backend.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "eudistack-issuer-core-backend.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Support for existing database secret
*/}}
{{- define "eudistack-issuer-core-backend.db-secretName" -}}
    {{- if .Values.app.db.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.db.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "%s" (include "eudistack-issuer-core-backend.fullname" .) | quote -}}
    {{- end -}}
{{- end -}}

{{- define "eudistack-issuer-core-backend.db-passwordKey" -}}
    {{- if .Values.app.db.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.db.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "postgres-password" -}}
    {{- end -}}
{{- end -}}

{{/*
Support for existing auth server client secret
*/}}
{{- define "eudistack-issuer-core-backend.authServerClient-secretName" -}}
    {{- if .Values.app.authServer.client.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.authServer.client.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "%s" (include "eudistack-issuer-core-backend.fullname" .) | quote -}}
    {{- end -}}
{{- end -}}

{{- define "eudistack-issuer-core-backend.authServerClient-passwordKey" -}}
    {{- if .Values.app.authServer.client.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.authServer.client.existingSecret.clientPasswordKey $) -}}
    {{- else -}}
        {{- printf "auth-server-password" -}}
    {{- end -}}
{{- end -}}

{{/*
Support for existing mail secret
*/}}
{{- define "eudistack-issuer-core-backend.mail-secretName" -}}
    {{- if .Values.app.mail.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.mail.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "%s" (include "eudistack-issuer-core-backend.fullname" .) | quote -}}
    {{- end -}}
{{- end -}}

{{- define "eudistack-issuer-core-backend.mail-userKey" -}}
    {{- if .Values.app.mail.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.mail.existingSecret.userKey $) -}}
    {{- else -}}
        {{- printf "mail-username" -}}
    {{- end -}}
{{- end -}}

{{- define "eudistack-issuer-core-backend.mail-passwordKey" -}}
    {{- if .Values.app.mail.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.mail.existingSecret.passwordKey $) -}}
    {{- else -}}
        {{- printf "mail-password" -}}
    {{- end -}}
{{- end -}}

{{/*
Support for existing issuer identity secret
*/}}
{{- define "eudistack-issuer-core-backend.issuerIdentity-secretName" -}}
    {{- if .Values.app.issuerIdentity.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.issuerIdentity.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "%s" (include "eudistack-issuer-core-backend.fullname" .) | quote -}}
    {{- end -}}
{{- end -}}

{{- define "eudistack-issuer-core-backend.issuerIdentity-privateKey" -}}
    {{- if .Values.app.issuerIdentity.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.issuerIdentity.existingSecret.privateKey $) -}}
    {{- else -}}
        {{- printf "issuer-identity-private-key" -}}
    {{- end -}}
{{- end -}}

{{- define "eudistack-issuer-core-backend.issuerIdentity-vc" -}}
    {{- if .Values.app.issuerIdentity.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.issuerIdentity.existingSecret.vc $) -}}
    {{- else -}}
        {{- printf "issuer-identity-vc" -}}
    {{- end -}}
{{- end -}}

{{- define "eudistack-issuer-core-backend.issuerIdentity-credentialDidKey" -}}
    {{- if .Values.app.issuerIdentity.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.issuerIdentity.existingSecret.credentialDidKey $) -}}
    {{- else -}}
        {{- printf "issuer-identity-credential-did-key" -}}
    {{- end -}}
{{- end -}}

{{/*
Support for existing default signer secret
*/}}
{{- define "eudistack-issuer-core-backend.defaultSigner-secretName" -}}
    {{- if .Values.app.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.defaultSigner.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "%s" (include "eudistack-issuer-core-backend.fullname" .) | quote -}}
    {{- end -}}
{{- end -}}

{{- define "eudistack-issuer-core-backend.defaultSigner-commonName" -}}
    {{- if .Values.app.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.defaultSigner.existingSecret.commonName $) -}}
    {{- else -}}
        {{- printf "default-signer-common-name" -}}
    {{- end -}}
{{- end -}}

{{- define "eudistack-issuer-core-backend.defaultSigner-organization" -}}
    {{- if .Values.app.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.defaultSigner.existingSecret.organization $) -}}
    {{- else -}}
        {{- printf "default-signer-organization" -}}
    {{- end -}}
{{- end -}}

{{- define "eudistack-issuer-core-backend.defaultSigner-country" -}}
    {{- if .Values.app.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.defaultSigner.existingSecret.country $) -}}
    {{- else -}}
        {{- printf "default-signer-country" -}}
    {{- end -}}
{{- end -}}

{{- define "eudistack-issuer-core-backend.defaultSigner-email" -}}
    {{- if .Values.app.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.defaultSigner.existingSecret.email $) -}}
    {{- else -}}
        {{- printf "default-signer-email" -}}
    {{- end -}}
{{- end -}}

{{- define "eudistack-issuer-core-backend.defaultSigner-organizationIdentifier" -}}
    {{- if .Values.app.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.defaultSigner.existingSecret.organizationIdentifier $) -}}
    {{- else -}}
        {{- printf "default-signer-organization-identifier" -}}
    {{- end -}}
{{- end -}}

{{- define "eudistack-issuer-core-backend.defaultSigner-serialNumber" -}}
    {{- if .Values.app.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.defaultSigner.existingSecret.serialNumber $) -}}
    {{- else -}}
        {{- printf "default-signer-serial-number" -}}
    {{- end -}}
{{- end -}}

Support for existing vault secret
*/}}
{{- define "eudistack-issuer-core-backend.vaultTokenSecretName" -}}
  {{- if .Values.app.vault.existingSecret.enabled -}}
    {{- printf "%s" .Values.app.vault.existingSecret.name | quote -}}
  {{- else -}}
    {{- printf "%s" (include "eudistack-issuer-core-backend.fullname" .) | quote -}}
  {{- end }}
{{- end }}


{{- define "eudistack-issuer-core-backend.vaultTokenSecretKey" -}}
  {{- if .Values.app.vault.existingSecret.enabled -}}
    {{- printf "%s" .Values.app.vault.existingSecret.key | quote -}}
  {{- else -}}
    {{- printf "%s" "vault-token" | quote -}}
  {{- end }}
{{- end }}

{{/*
Internal Server Port
*/}}
{{- define "eudistack-issuer-core-backend.serverPort" -}}
{{- default 8080 }}
{{- end }}
