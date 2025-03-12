{{/*
Expand the name of the chart.
*/}}
{{- define "wallet-backend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "wallet-backend.fullname" -}}
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
{{- define "wallet-backend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "wallet-backend.labels" -}}
helm.sh/chart: {{ include "wallet-backend.chart" . }}
{{ include "wallet-backend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "wallet-backend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "wallet-backend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "wallet-backend.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "wallet-backend.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Support for existing secrets
*/}}
{{- define "wallet-backend.secretName" -}}
    {{- if .Values.app.db.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.db.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "wallet-backend-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "wallet-backend.secretKey" -}}
    {{- if .Values.app.db.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.db.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "postgres-password" -}}
    {{- end -}}
{{- end -}}

{{- define "wallet-backend.clientSecretKey" -}}
    {{- if .Values.app.ebsiTest.client.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.ebsiTest.client.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "ebsi-client-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "wallet-backend.userPasswordKey" -}}
    {{- if .Values.app.ebsiTest.userData.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.ebsiTest.userData.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "ebsi-user-password" -}}
    {{- end -}}
{{- end -}}

{{- define "wallet-backend.vaultTokenKey" -}}
    {{- if .Values.app.vault.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.vault.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "vault-token" -}}
    {{- end -}}
{{- end -}}

{{- define "keycloak.domain" -}}
{{- if eq .Values.global.environment "prod" -}}
    keycloak.{{ .Values.global.externalDomain }}
{{- else -}}
    keycloak-{{ .Values.global.environment }}.{{ .Values.global.externalDomain }}
{{- end }}
{{- end }}

{{/*
Internal Server Port
*/}}
{{- define "wallet-backend.serverPort" -}}
{{- default 8080 }}
{{- end }}