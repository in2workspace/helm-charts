{{/*
Expand the name of the chart.
*/}}
{{- define "issuer-frontend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "issuer-frontend.fullname" -}}
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
{{- define "issuer-frontend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "issuer-frontend.labels" -}}
helm.sh/chart: {{ include "issuer-frontend.chart" . }}
{{ include "issuer-frontend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "issuer-frontend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "issuer-frontend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "issuer-frontend.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "issuer-frontend.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Internal Server Port
*/}}
{{- define "issuer-frontend.serverPort" -}}
{{- default 8080 }}
{{- end }}

{{/*
Logo file src
*/}}
{{- define "issuer-frontend.logoSrc" -}}
assets/logos/{{ .Values.global.tenantName }}-logo.png
{{- end }}

{{/*
Favicon file src
*/}}
{{- define "issuer-frontend.faviconSrc" -}}
assets/icons/{{ .Values.global.tenantName }}-favicon.png
{{- end }}

{{/*
Keycloak External Domain
*/}}
{{- define "issuer-frontend.keycloakExternalDomain" -}}
{{- if eq .Values.global.environment "prod" -}}
    keycloak.{{ .Values.global.externalDomain }}
{{- else -}}
    keycloak-{{ .Values.global.environment }}.{{ .Values.global.externalDomain }}
{{- end }}
{{- end }}