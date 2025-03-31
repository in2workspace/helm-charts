{{/*
Expand the name of the chart.
*/}}
{{- define "dome-verifier.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dome-verifier.fullname" -}}
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
{{- define "dome-verifier.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "dome-verifier.labels" -}}
helm.sh/chart: {{ include "dome-verifier.chart" . }}
{{ include "dome-verifier.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dome-verifier.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dome-verifier.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "dome-verifier.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "dome-verifier.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Support for secrets
*/}}
{{- define "dome-verifier.verifierSecretFileName" -}}
    {{- if .Values.app.backend.security.serviceIdentity.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.backend.security.serviceIdentity.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "private-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "dome-verifier.privateKey-key" -}}
    {{- if .Values.app.backend.security.serviceIdentity.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.backend.security.serviceIdentity.existingSecret.privateKey $) -}}
    {{- else -}}
        {{- printf "private-key" -}}
    {{- end -}}
{{- end -}}

{{- define "dome-verifier.learCredentialMachine-key" -}}
    {{- if .Values.app.backend.security.serviceIdentity.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.backend.security.serviceIdentity.existingSecret.verifiableCredential $) -}}
    {{- else -}}
        {{- printf "vc" -}}
    {{- end -}}
{{- end -}}

{{/*
Internal Server Port
*/}}
{{- define "dome-verifier.serverPort" -}}
{{- default 8080 }}
{{- end }}
