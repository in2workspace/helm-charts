{{/*
Expand the name of the chart.
*/}}
{{- define "verifier-api.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "verifier-api.fullname" -}}
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
{{- define "verifier-api.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "verifier-api.labels" -}}
helm.sh/chart: {{ include "verifier-api.chart" . }}
{{ include "verifier-api.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "verifier-api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "verifier-api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "verifier-api.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "verifier-api.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Support for private key secret
*/}}
{{- define "verifier-api.privateKey-secretName" -}}
    {{- if .Values.app.privateKey.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.privateKey.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "verifier-api-private-key-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "verifier-api.privateKey-privateKey" -}}
    {{- if .Values.app.privateKey.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.privateKey.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "privateKey" -}}
    {{- end -}}
{{- end -}}

{{/*
Defines internal server port, which should not be modified by user
If internalServerPort is not set, 8080 will be assigned
*/}}
{{- define "verifier-api.internalServerPort" -}}
    {{- if .Values.internalServerPort -}}
        {{- .Values.internalServerPort -}}
    {{- else -}}
        {{- printf "8080" -}}
    {{- end -}}
{{- end -}}
