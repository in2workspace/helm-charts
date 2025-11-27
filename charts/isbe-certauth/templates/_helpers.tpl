{{/*
Expand the name of the chart.
*/}}
{{- define "isbe-certauth.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "isbe-certauth.fullname" -}}
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
{{- define "isbe-certauth.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "isbe-certauth.labels" -}}
helm.sh/chart: {{ include "isbe-certauth.chart" . }}
{{ include "isbe-certauth.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "isbe-certauth.selectorLabels" -}}
app.kubernetes.io/name: {{ include "isbe-certauth.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "isbe-certauth.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "isbe-certauth.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "isbe-certauth.CertAuthAdminPasswordSecretName" -}}
    {{- if .Values.env.certAuthAdminPassword.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.certAuthAdminPassword.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "isbe-certauth-admin-password-secret" -}}
    {{- end -}}
{{- end -}}
{{- define "isbe-certauth.CertAuthAdminPasswordKey" -}}
    {{- if .Values.env.certAuthAdminPassword.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.certAuthAdminPassword.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "certauth-admin-password" -}}
    {{- end -}}
{{- end -}}
