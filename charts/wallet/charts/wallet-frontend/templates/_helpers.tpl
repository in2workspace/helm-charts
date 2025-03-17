{{/*
Expand the name of the chart.
*/}}
{{- define "wallet-frontend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "wallet-frontend.fullname" -}}
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
{{- define "wallet-frontend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "wallet-frontend.labels" -}}
helm.sh/chart: {{ include "wallet-frontend.chart" . }}
{{ include "wallet-frontend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "wallet-frontend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "wallet-frontend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "wallet-frontend.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "wallet-frontend.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Wallet Backend External Domain
*/}}
{{- define "wallet-backend.domain" -}}
{{- if eq .Values.global.environment "prod" -}}
    wallet.{{ .Values.global.tenantName }}.{{ .Values.global.externalDomain }}/api
{{- else -}}
    wallet-{{ .Values.global.environment }}.{{ .Values.global.tenantName }}.{{ .Values.global.externalDomain }}/api
{{- end }}
{{- end }}

{{/*
Internal Server Port
*/}}
{{- define "wallet-frontend.serverPort" -}}
{{- default 8080 }}
{{- end }}

{{/*
Keycloak domain
*/}}
{{- define "keycloak.domain" -}}
{{- if eq .Values.global.environment "prod" -}}
    keycloak.{{ .Values.global.externalDomain }}
{{- else -}}
    keycloak-{{ .Values.global.environment }}.{{ .Values.global.externalDomain }}
{{- end }}
{{- end }}

{{/*
Logo file src
*/}}
{{- define "wallet-frontend.logoSrc" -}}
assets/logos/{{ .Values.global.tenantName }}-logo.png
{{- end }}

{{/*
Favicon file src
*/}}
{{- define "wallet-frontend.faviconSrc" -}}
assets/icons/{{ .Values.global.tenantName }}-favicon.png
{{- end }}
