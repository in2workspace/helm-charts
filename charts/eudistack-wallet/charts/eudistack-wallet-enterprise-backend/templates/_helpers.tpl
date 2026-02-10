{{/*
Expand the name of the chart.
*/}}
{{- define "eudistack-wallet-enterprise-backend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "eudistack-wallet-enterprise-backend.fullname" -}}
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
{{- define "eudistack-wallet-enterprise-backend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "eudistack-wallet-enterprise-backend.labels" -}}
helm.sh/chart: {{ include "eudistack-wallet-enterprise-backend.chart" . }}
{{ include "eudistack-wallet-enterprise-backend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "eudistack-wallet-enterprise-backend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "eudistack-wallet-enterprise-backend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "eudistack-wallet-enterprise-backend.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "eudistack-wallet-enterprise-backend.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Support for existing vault secret
*/}}
{{- define "eudistack-wallet-enterprise-backend.vaultTokenSecretName" -}}
  {{- if .Values.app.vault.existingSecret.enabled -}}
    {{- printf "%s" .Values.app.vault.existingSecret.name | quote -}}
  {{- else -}}
    {{- printf "%s" (include "eudistack-wallet-enterprise-backend.fullname" .) | quote -}}
  {{- end }}
{{- end }}


{{- define "eudistack-wallet-enterprise-backend.vaultTokenSecretKey" -}}
  {{- if .Values.app.vault.existingSecret.enabled -}}
    {{- printf "%s" .Values.app.vault.existingSecret.key | quote -}}
  {{- else -}}
    {{- printf "%s" "vault-token" | quote -}}
  {{- end }}
{{- end }}

{{/*
Support for existing ebsiTest client secret
*/}}
{{- define "eudistack-wallet-enterprise-backend.ebsiClientSecretName" -}}
  {{- if .Values.app.ebsiTest.client.existingSecret.enabled -}}
    {{- printf "%s" .Values.app.ebsiTest.client.existingSecret.name | quote -}}
  {{- else -}}
    {{- printf "%s" (include "eudistack-wallet-enterprise-backend.fullname" .) | quote -}}
  {{- end }}
{{- end }}

{{- define "eudistack-wallet-enterprise-backend.ebsiClientSecretKey" -}}
  {{- if .Values.app.ebsiTest.client.existingSecret.enabled -}}
    {{- printf "%s" .Values.app.ebsiTest.client.existingSecret.key | quote -}}
  {{- else -}}
    {{- printf "%s" "ebsi-client-secret" | quote -}}
  {{- end }}
{{- end }}


{{/*
Support for existing ebsiTest userData secret
*/}}
{{- define "eudistack-wallet-enterprise-backend.ebsiUserSecretName" -}}
  {{- if .Values.app.ebsiTest.userData.existingSecret.enabled -}}
    {{- printf "%s" .Values.app.ebsiTest.userData.existingSecret.name | quote -}}
  {{- else -}}
    {{- printf "%s" (include "eudistack-wallet-enterprise-backend.fullname" .) | quote -}}
  {{- end }}
{{- end }}

{{- define "eudistack-wallet-enterprise-backend.ebsiUserSecretKey" -}}
  {{- if .Values.app.ebsiTest.userData.existingSecret.enabled -}}
    {{- printf "%s" .Values.app.ebsiTest.userData.existingSecret.key | quote -}}
  {{- else -}}
    {{- printf "%s" "ebsi-user-password" | quote -}}
  {{- end }}
{{- end }}


{{/*
Support for existing db secret
*/}}
{{- define "eudistack-wallet-enterprise-backend.dbSecretName" -}}
  {{- if .Values.app.db.existingSecret.enabled -}}
    {{- printf "%s" .Values.app.db.existingSecret.name | quote -}}
  {{- else -}}
    {{- printf "%s" (include "eudistack-wallet-enterprise-backend.fullname" .) | quote -}}
  {{- end }}
{{- end }}

{{- define "eudistack-wallet-enterprise-backend.dbSecretKey" -}}
  {{- if .Values.app.db.existingSecret.enabled -}}
    {{- printf "%s" .Values.app.db.existingSecret.key | quote -}}
  {{- else -}}
    {{- printf "%s" "postgres-password" | quote -}}
  {{- end }}
{{- end }}

{{/*
Internal Server Port
*/}}
{{- define "eudistack-wallet-enterprise-backend.serverPort" -}}
{{- default 8080 }}
{{- end }}