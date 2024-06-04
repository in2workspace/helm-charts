{{/*
Expand the name of the chart.
*/}}
{{- define "wallet-keycloak.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "wallet-keycloak.fullname" -}}
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
{{- define "wallet-keycloak.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "wallet-keycloak.labels" -}}
helm.sh/chart: {{ include "wallet-keycloak.chart" . }}
{{ include "wallet-keycloak.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "wallet-keycloak.selectorLabels" -}}
app.kubernetes.io/name: {{ include "wallet-keycloak.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "wallet-keycloak.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "wallet-keycloak.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Support for existing database secret 
*/}}
{{- define "wallet-keycloak.dbSecretName" -}}
    {{- if .Values.db.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.db.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "%s" (include "wallet-keycloak.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{- define "wallet-keycloak.db-passwordKey" -}}
    {{- if .Values.db.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.db.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "keycloak-db-password" -}}
    {{- end -}}
{{- end -}}

{{- define "wallet-keycloak.keycloakSecretName" -}}
    {{- if .Values.app.keycloak.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.db.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "%s" (include "wallet-keycloak.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{- define "wallet-keycloak.keycloak-passwordKey" -}}
    {{- if .Values.app.keycloak.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.keycloak.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "keycloak-password" -}}
    {{- end -}}
{{- end -}}