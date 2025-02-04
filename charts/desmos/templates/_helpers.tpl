{{/*
Expand the name of the chart.
*/}}
{{- define "desmos.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "desmos.fullname" -}}
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
{{- define "desmos.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "desmos.labels" -}}
helm.sh/chart: {{ include "desmos.chart" . }}
{{ include "desmos.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "desmos.selectorLabels" -}}
app.kubernetes.io/name: {{ include "desmos.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "desmos.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "desmos.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Support for existing database secret 
*/}}
{{- define "desmos.secretName" -}}
    {{- if .Values.db.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.db.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "%s" (include "desmos.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{- define "desmos.passwordKey" -}}
    {{- if .Values.db.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.db.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "desmos-db-password" -}}
    {{- end -}}
{{- end -}}

{{/*
Support for private key secret
*/}}
{{- define "desmos.privateKey-secretName" -}}
    {{- if .Values.app.privateKey.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.privateKey.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "desmos-private-key-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "desmos.privateKey-privateKey" -}}
    {{- if .Values.app.privateKey.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.privateKey.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "privateKey" -}}
    {{- end -}}
{{- end -}}

{{/*
Support for lear credential machine secret
*/}}
{{- define "desmos.learCredentialMachine-secretName" -}}
    {{- if .Values.app.learCredentialMachineInBase64.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.learCredentialMachineInBase64.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "desmos-lear-credential-machine-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "desmos.learCredentialMachine-learCredentialMachine" -}}
    {{- if .Values.app.learCredentialMachineInBase64.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.learCredentialMachineInBase64.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "learCredentialMachine" -}}
    {{- end -}}
{{- end -}}