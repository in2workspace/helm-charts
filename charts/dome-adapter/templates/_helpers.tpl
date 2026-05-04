{{/*
Expand the name of the chart.
*/}}
{{- define "dome-adapter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "dome-adapter.key.r2dbcUsername" -}}
{{- .Values.spring.r2dbc.existingSecret.username -}}
{{- end -}}

{{- define "dome-adapter.key.r2dbcPassword" -}}
{{- .Values.spring.r2dbc.existingSecret.password -}}
{{- end -}}

{{- define "dome-adapter.key.mailUsername" -}}
{{- .Values.spring.mail.existingSecret.username -}}
{{- end -}}

{{- define "dome-adapter.key.mailPassword" -}}
{{- .Values.spring.mail.existingSecret.password -}}
{{- end -}}

{{- define "dome-adapter.key.jwtCredential" -}}
{{- index .Values "adapter-identity" "existingSecret" "jwtCredential" -}}
{{- end -}}

{{- define "dome-adapter.key.privateKey" -}}
{{- index .Values "adapter-identity" "existingSecret" "privateKey" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dome-adapter.fullname" -}}
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
{{- define "dome-adapter.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "dome-adapter.labels" -}}
helm.sh/chart: {{ include "dome-adapter.chart" . }}
{{ include "dome-adapter.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dome-adapter.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dome-adapter.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "dome-adapter.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "dome-adapter.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Internal server port (matches server.port in application.yml)
*/}}
{{- define "dome-adapter.serverPort" -}}
{{- 8081 -}}
{{- end }}

{{/* ---- R2DBC secret ---- */}}

{{- define "dome-adapter.r2dbcSecretName" -}}
{{- if .Values.spring.r2dbc.existingSecret.enabled -}}
{{- tpl .Values.spring.r2dbc.existingSecret.name $ -}}
{{- else -}}
{{- .Values.secret.name -}}
{{- end -}}
{{- end -}}

{{/* ---- Mail secret ---- */}}

{{- define "dome-adapter.mailSecretName" -}}
{{- if .Values.spring.mail.existingSecret.enabled -}}
{{- tpl .Values.spring.mail.existingSecret.name $ -}}
{{- else -}}
{{- .Values.secret.name -}}
{{- end -}}
{{- end -}}

{{/* ---- Adapter identity secret ---- */}}

{{- define "dome-adapter.identitySecretName" -}}
{{- $ai := index .Values "adapter-identity" -}}
{{- if $ai.existingSecret.enabled -}}
{{- tpl $ai.existingSecret.name $ -}}
{{- else -}}
{{- $.Values.secret.name -}}
{{- end -}}
{{- end -}}
