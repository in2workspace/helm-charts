{{/*
Expand the name of the chart.
*/}}
{{- define "dss.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dss.fullname" -}}
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
{{- define "dss.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "dss.labels" -}}
helm.sh/chart: {{ include "dss.chart" . }}
{{ include "dss.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dss.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dss.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "dss.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "dss.fullname" .) .Values.serviceAccount.name | quote -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name | quote -}}
{{- end -}}
{{- end }}

{{- define "dss.vaultTokenSecretName" -}}
    {{- if .Values.app.vault.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.vault.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "dss-token-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "dss.user-tokenKey" -}}
    {{- if .Values.app.vault.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.vault.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "token" -}}
    {{- end -}}
{{- end -}}

{{- define "dss.certificateSecretName" -}}
    {{- if .Values.app.certificate.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.certificate.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "dss-certificate-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "dss.certificate-passwordKey" -}}
    {{- if .Values.app.certificate.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.certificate.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "password" -}}
    {{- end -}}
{{- end -}}