{{/*
Expand the name of the chart.
*/}}
{{- define "verifier.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "verifier.fullname" -}}
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
{{- define "verifier.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "verifier.labels" -}}
helm.sh/chart: {{ include "verifier.chart" . }}
{{ include "verifier.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "verifier.selectorLabels" -}}
app.kubernetes.io/name: {{ include "verifier.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "verifier.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "verifier.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Support for private key secret
*/}}
{{- define "verifier.privateKey-secretName" -}}
    {{- if .Values.app.backend.security.serviceIdentity.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.backend.security.serviceIdentity.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "verifier-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "verifier.privateKey-key" -}}
    {{- if .Values.app.backend.security.serviceIdentity.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.backend.security.serviceIdentity.existingSecret.privateKey $) -}}
    {{- else -}}
        {{- printf "private-key" -}}
    {{- end -}}
{{- end -}}

{{- define "verifier.learCredentialMachine-key" -}}
    {{- if .Values.app.backend.security.serviceIdentity.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.backend.security.serviceIdentity.existingSecret.verifiableCredential $) -}}
    {{- else -}}
        {{- printf "verifiable-credential" -}}
    {{- end -}}
{{- end -}}

{{/*
Internal Server Port
*/}}
{{- define "verifier.serverPort" -}}
{{- default 8080 }}
{{- end }}

{{/*
Logo file src
*/}}
{{- define "verifier-frontend.logoSrc" -}}
assets/logos/{{ .Values.global.tenantName }}-logo.png
{{- end }}

{{/*
Favicon file src
*/}}
{{- define "verifier-frontend.faviconSrc" -}}
assets/icons/{{ .Values.global.tenantName }}-favicon.png
{{- end }}

{{/*
Verifier domain
*/}}
{{- define "verifier.domain" -}}
{{- if eq .Values.global.environment "prod" -}}
    verifier.{{ .Values.global.tenantName }}.{{ .Values.global.externalDomain }}
{{- else -}}
    verifier-{{ .Values.global.environment }}.{{ .Values.global.tenantName }}.{{ .Values.global.externalDomain }}
{{- end }}
{{- end }}