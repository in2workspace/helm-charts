{{/*
Expand the name of the chart.
*/}}
{{- define "dome-wallet-backend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dome-wallet-backend.fullname" -}}
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
{{- define "dome-wallet-backend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "dome-wallet-backend.labels" -}}
helm.sh/chart: {{ include "dome-wallet-backend.chart" . }}
{{ include "dome-wallet-backend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dome-wallet-backend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dome-wallet-backend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "dome-wallet-backend.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "dome-wallet-backend.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Support for existing vault secret
*/}}
{{- define "dome-wallet-backend.vaultTokenSecretName" -}}
  {{- if .Values.app.vault.existingSecret.enabled -}}
    {{- printf "%s" .Values.app.vault.existingSecret.name | quote -}}
  {{- else -}}
    {{- printf "%s" (include "dome-wallet-backend.fullname" .) | quote -}}
  {{- end }}
{{- end }}


{{- define "dome-wallet-backend.vaultTokenSecretKey" -}}
  {{- if .Values.app.vault.existingSecret.enabled -}}
    {{- printf "%s" .Values.app.vault.existingSecret.key | quote -}}
  {{- else -}}
    {{- printf "%s" "vault-token" | quote -}}
  {{- end }}
{{- end }}

{{/*
Support for existing ebsiTest client secret
*/}}
{{- define "dome-wallet-backend.ebsiClientSecretName" -}}
  {{- if .Values.app.ebsiTest.client.existingSecret.enabled -}}
    {{- printf "%s" .Values.app.ebsiTest.client.existingSecret.name | quote -}}
  {{- else -}}
    {{- printf "%s" (include "dome-wallet-backend.fullname" .) | quote -}}
  {{- end }}
{{- end }}

{{- define "dome-wallet-backend.ebsiClientSecretKey" -}}
  {{- if .Values.app.ebsiTest.client.existingSecret.enabled -}}
    {{- printf "%s" .Values.app.ebsiTest.client.existingSecret.key | quote -}}
  {{- else -}}
    {{- printf "%s" "ebsi-client-secret" | quote -}}
  {{- end }}
{{- end }}


{{/*
Support for existing ebsiTest userData secret
*/}}
{{- define "dome-wallet-backend.ebsiUserSecretName" -}}
  {{- if .Values.app.ebsiTest.userData.existingSecret.enabled -}}
    {{- printf "%s" .Values.app.ebsiTest.userData.existingSecret.name | quote -}}
  {{- else -}}
    {{- printf "%s" (include "dome-wallet-backend.fullname" .) | quote -}}
  {{- end }}
{{- end }}

{{- define "dome-wallet-backend.ebsiUserSecretKey" -}}
  {{- if .Values.app.ebsiTest.userData.existingSecret.enabled -}}
    {{- printf "%s" .Values.app.ebsiTest.userData.existingSecret.key | quote -}}
  {{- else -}}
    {{- printf "%s" "ebsi-user-password" | quote -}}
  {{- end }}
{{- end }}


{{/*
Support for existing db secret
*/}}
{{- define "dome-wallet-backend.dbSecretName" -}}
  {{- if .Values.app.db.existingSecret.enabled -}}
    {{- printf "%s" .Values.app.db.existingSecret.name | quote -}}
  {{- else -}}
    {{- printf "%s" (include "dome-wallet-backend.fullname" .) | quote -}}
  {{- end }}
{{- end }}

{{- define "dome-wallet-backend.dbSecretKey" -}}
  {{- if .Values.app.db.existingSecret.enabled -}}
    {{- printf "%s" .Values.app.db.existingSecret.key | quote -}}
  {{- else -}}
    {{- printf "%s" "postgres-password" | quote -}}
  {{- end }}
{{- end }}

{{/*
Internal Server Port
*/}}
{{- define "dome-wallet-backend.serverPort" -}}
{{- default 8080 }}
{{- end }}