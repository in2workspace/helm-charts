{{/*
Expand the name of the chart.
*/}}
{{- define "dome-issuer-keycloak.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dome-issuer-keycloak.fullname" -}}
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
{{- define "dome-issuer-keycloak.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "dome-issuer-keycloak.labels" -}}
helm.sh/chart: {{ include "dome-issuer-keycloak.chart" . }}
{{ include "dome-issuer-keycloak.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dome-issuer-keycloak.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dome-issuer-keycloak.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "dome-issuer-keycloak.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "dome-issuer-keycloak.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Support for existing keycloak admin secret 
*/}}
{{- define "dome-issuer-keycloak.admin-secretName" -}}
    {{- if .Values.app.keycloak.admin.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.keycloak.admin.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "%s" (include "dome-issuer-keycloak.fullname" .) | quote -}}
    {{- end -}}
{{- end -}}

{{- define "dome-issuer-keycloak.admin-passwordKey" -}}
    {{- if .Values.app.keycloak.admin.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.keycloak.admin.existingSecret.passwordKey $) -}}
    {{- else -}}
        {{- printf "keycloak-password" -}}
    {{- end -}}
{{- end -}}

{{/*
Support for existing keycloak db secret 
*/}}
{{- define "dome-issuer-keycloak.db-secretName" -}}
    {{- if .Values.app.db.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.db.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "%s" (include "dome-issuer-keycloak.fullname" .) | quote -}}
    {{- end -}}
{{- end -}}

{{- define "dome-issuer-keycloak.db-passwordKey" -}}
    {{- if .Values.app.db.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.db.existingSecret.passwordKey $) -}}
    {{- else -}}
        {{- printf "keycloak-db-password" -}}
    {{- end -}}
{{- end -}}

{{/*
Internal Server Port
*/}}
{{- define "dome-issuer-keycloak.serverPort" -}}
{{- default 8080 }}
{{- end }}