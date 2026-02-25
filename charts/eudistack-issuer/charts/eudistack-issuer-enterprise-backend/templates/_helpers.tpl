{{/*
Expand the name of the chart.
*/}}
{{- define "eudistack-issuer-enterprise-backend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "eudistack-issuer-enterprise-backend.fullname" -}}
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
{{- define "eudistack-issuer-enterprise-backend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "eudistack-issuer-enterprise-backend.labels" -}}
helm.sh/chart: {{ include "eudistack-issuer-enterprise-backend.chart" . }}
{{ include "eudistack-issuer-enterprise-backend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "eudistack-issuer-enterprise-backend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "eudistack-issuer-enterprise-backend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "eudistack-issuer-enterprise-backend.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "eudistack-issuer-enterprise-backend.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Support for existing remote-signature-secret
*/}}

{{- define "eudistack-issuer-enterprise-backend.remoteSignature-secretName" -}}
    {{- if .Values.app.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.remoteSignature.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "%s" (include "eudistack-issuer-enterprise-backend.fullname" .) | quote -}}
    {{- end -}}
{{- end -}}

{{- define "eudistack-issuer-enterprise-backend.remoteSignature-clientId" -}}
    {{- if .Values.app.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.remoteSignature.existingSecret.clientId $) -}}
    {{- else -}}
        {{- printf "remote-signature-client-id" -}}
    {{- end -}}
{{- end -}}

{{- define "eudistack-issuer-enterprise-backend.remoteSignature-clientSecret" -}}
    {{- if .Values.app.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.remoteSignature.existingSecret.clientSecret $) -}}
    {{- else -}}
        {{- printf "remote-signature-client-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "eudistack-issuer-enterprise-backend.remoteSignature-credentialId" -}}
    {{- if .Values.app.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.remoteSignature.existingSecret.credentialId $) -}}
    {{- else -}}
        {{- printf "remote-signature-credential-id" -}}
    {{- end -}}
{{- end -}}

{{- define "eudistack-issuer-enterprise-backend.remoteSignature-credentialPassword" -}}
    {{- if .Values.app.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.remoteSignature.existingSecret.credentialPassword $) -}}
    {{- else -}}
        {{- printf "remote-signature-credential-password" -}}
    {{- end -}}
{{- end -}}

{{/*
Internal Server Port
*/}}
{{- define "eudistack-issuer-enterprise-backend.serverPort" -}}
{{- default 8080 }}
{{- end }}
