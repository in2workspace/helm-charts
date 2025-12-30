{{/*
Expand the name of the chart.
*/}}
{{- define "isbe-certauth.name" -}}
{{- default .Chart.Name .Values.appName | trunc 63 | trimSuffix "-" }}
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
{{- $name := default .Chart.Name .Values.appName }}
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
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
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

{{/*
Admin Password Secret Name
*/}}
{{- define "isbe-certauth.adminPassword.secretName" -}}
{{- if .Values.adminPassword.existingSecret.enabled -}}
{{- printf "%s" (tpl .Values.adminPassword.existingSecret.name $) -}}
{{- else -}}
{{- printf "%s-admin" (include "isbe-certauth.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "isbe-certauth.adminPassword.key" -}}
{{- if .Values.adminPassword.existingSecret.enabled -}}
{{- printf "%s" (tpl .Values.adminPassword.existingSecret.key $) -}}
{{- else -}}
{{- printf "admin-password" -}}
{{- end -}}
{{- end -}}

{{/*
TSA Credentials Secret Name and Keys
*/}}
{{- define "isbe-certauth.tsaCredentials.secretName" -}}
{{- if .Values.tsaCredentials.existingSecret.enabled -}}
{{- printf "%s" (tpl .Values.tsaCredentials.existingSecret.name $) -}}
{{- else -}}
{{- printf "%s-tsa" (include "isbe-certauth.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "isbe-certauth.tsaCredentials.userKey" -}}
{{- if .Values.tsaCredentials.existingSecret.enabled -}}
{{- printf "%s" (tpl .Values.tsaCredentials.existingSecret.userKey $) -}}
{{- else -}}
{{- printf "tsa-user" -}}
{{- end -}}
{{- end -}}

{{- define "isbe-certauth.tsaCredentials.passwordKey" -}}
{{- if .Values.tsaCredentials.existingSecret.enabled -}}
{{- printf "%s" (tpl .Values.tsaCredentials.existingSecret.passwordKey $) -}}
{{- else -}}
{{- printf "tsa-password" -}}
{{- end -}}
{{- end -}}

{{/*
SMTP Credentials Secret Name and Keys
*/}}
{{- define "isbe-certauth.smtpCredentials.secretName" -}}
{{- if .Values.smtpCredentials.existingSecret.enabled -}}
{{- printf "%s" (tpl .Values.smtpCredentials.existingSecret.name $) -}}
{{- else -}}
{{- printf "%s-smtp" (include "isbe-certauth.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "isbe-certauth.smtpCredentials.usernameKey" -}}
{{- if .Values.smtpCredentials.existingSecret.enabled -}}
{{- printf "%s" (tpl .Values.smtpCredentials.existingSecret.usernameKey $) -}}
{{- else -}}
{{- printf "smtp-username" -}}
{{- end -}}
{{- end -}}

{{- define "isbe-certauth.smtpCredentials.passwordKey" -}}
{{- if .Values.smtpCredentials.existingSecret.enabled -}}
{{- printf "%s" (tpl .Values.smtpCredentials.existingSecret.passwordKey $) -}}
{{- else -}}
{{- printf "smtp-password" -}}
{{- end -}}
{{- end -}}

{{/*
Profile Secret Name and Key
*/}}
{{- define "isbe-certauth.profile.secretName" -}}
{{- if .Values.profile.existingSecret.enabled -}}
{{- printf "%s" (tpl .Values.profile.existingSecret.name $) -}}
{{- else -}}
{{- printf "%s-profile" (include "isbe-certauth.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "isbe-certauth.profile.key" -}}
{{- if .Values.profile.existingSecret.enabled -}}
{{- printf "%s" (tpl .Values.profile.existingSecret.key $) -}}
{{- else -}}
{{- printf "profile" -}}
{{- end -}}
{{- end -}}