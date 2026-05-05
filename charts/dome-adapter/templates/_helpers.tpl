{{/*
Expand the name of the chart.
*/}}
{{- define "dome-adapter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

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

{{/*
Database Secret name
*/}}
{{- define "dome-adapter.db-secretName" -}}
{{- if .Values.app.db.existingSecret.enabled -}}
{{- .Values.app.db.existingSecret.name -}}
{{- else -}}
{{- include "dome-adapter.fullname" . -}}
{{- end -}}
{{- end }}

{{/*
Database password Secret key
*/}}
{{- define "dome-adapter.key.db-passwordKey" -}}
{{- if .Values.app.db.existingSecret.enabled -}}
{{- .Values.app.db.existingSecret.password -}}
{{- else -}}
postgres-password
{{- end -}}
{{- end }}

{{/*
Mail Secret name
*/}}
{{- define "dome-adapter.mail-secretName" -}}
{{- if .Values.spring.mail.existingSecret.enabled -}}
{{- .Values.spring.mail.existingSecret.name -}}
{{- else -}}
{{- include "dome-adapter.fullname" . -}}
{{- end -}}
{{- end }}

{{/*
Mail username Secret key
*/}}
{{- define "dome-adapter.key.mail-userKey" -}}
{{- if .Values.spring.mail.existingSecret.enabled -}}
{{- .Values.spring.mail.existingSecret.username -}}
{{- else -}}
mail-username
{{- end -}}
{{- end }}

{{/*
Mail password Secret key
*/}}
{{- define "dome-adapter.key.mail-passwordKey" -}}
{{- if .Values.spring.mail.existingSecret.enabled -}}
{{- .Values.spring.mail.existingSecret.password -}}
{{- else -}}
mail-password
{{- end -}}
{{- end }}

{{/*
Adapter identity Secret name
*/}}
{{- define "dome-adapter.identitySecretName" -}}
{{- if index .Values "adapter-identity" "existingSecret" "enabled" -}}
{{- index .Values "adapter-identity" "existingSecret" "name" -}}
{{- else -}}
{{- include "dome-adapter.fullname" . -}}
{{- end -}}
{{- end }}

{{/*
Adapter identity credential subject DID key Secret key
*/}}
{{- define "dome-adapter.key.credentialSubjectDidKey" -}}
{{- if index .Values "adapter-identity" "existingSecret" "enabled" -}}
{{- index .Values "adapter-identity" "existingSecret" "credentialSubjectDidKey" -}}
{{- else -}}
adapter-identity-credential-subject-did-key
{{- end -}}
{{- end }}

{{/*
Adapter identity JWT credential Secret key
*/}}
{{- define "dome-adapter.key.jwtCredential" -}}
{{- if index .Values "adapter-identity" "existingSecret" "enabled" -}}
{{- index .Values "adapter-identity" "existingSecret" "jwtCredential" -}}
{{- else -}}
adapter-identity-jwt-credential
{{- end -}}
{{- end }}

{{/*
Adapter identity private key Secret key
*/}}
{{- define "dome-adapter.key.privateKey" -}}
{{- if index .Values "adapter-identity" "existingSecret" "enabled" -}}
{{- index .Values "adapter-identity" "existingSecret" "privateKey" -}}
{{- else -}}
adapter-identity-private-key
{{- end -}}
{{- end }}
