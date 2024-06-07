{{/*
Expand the name of the chart.
*/}}
{{- define "wallet-api.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "wallet-api.fullname" -}}
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
{{- define "wallet-api.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "wallet-api.labels" -}}
helm.sh/chart: {{ include "wallet-api.chart" . }}
{{ include "wallet-api.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "wallet-api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "wallet-api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "wallet-api.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "wallet-api.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Support for existing database secret 
*/}}
{{- define "wallet-api.clientSecretName" -}}
    {{- if .Values.app.ebsiTest.client.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.ebsiTest.client.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "wallet-api-client-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "wallet-api.client-passwordKey" -}}
    {{- if .Values.app.ebsiTest.client.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.ebsiTest.client.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "client-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "wallet-api.userSecretName" -}}
    {{- if .Values.app.ebsiTest.userData.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.ebsiTest.userData.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "wallet-api-user-password" -}}
    {{- end -}}
{{- end -}}

{{- define "wallet-api.user-passwordKey" -}}
    {{- if .Values.app.ebsiTest.userData.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.ebsiTest.userData.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "user-password" -}}
    {{- end -}}
{{- end -}}

{{- define "wallet-api.vaultTokenSecretName" -}}
    {{- if .Values.app.vault.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.vault.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "wallet-api-token-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "wallet-api.user-tokenKey" -}}
    {{- if .Values.app.vault.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.vault.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "token" -}}
    {{- end -}}
{{- end -}}