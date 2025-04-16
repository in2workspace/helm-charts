{{/*
Expand the name of the chart.
*/}}
{{- define "dome-wallet-keycloak.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dome-wallet-keycloak.fullname" -}}
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
{{- define "dome-wallet-keycloak.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "dome-wallet-keycloak.labels" -}}
helm.sh/chart: {{ include "dome-wallet-keycloak.chart" . }}
{{ include "dome-wallet-keycloak.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dome-wallet-keycloak.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dome-wallet-keycloak.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "dome-wallet-keycloak.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "dome-wallet-keycloak.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Support for existing database secret
*/}}
{{- define "dome-wallet-keycloak.dbSecretName" -}}
    {{- if .Values.app.db.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.db.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "%s" (include "dome-wallet-keycloak.fullname" .) | quote -}}
    {{- end -}}
{{- end -}}

{{- define "dome-wallet-keycloak.db-passwordKey" -}}
    {{- if .Values.app.db.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.db.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "%s" "keycloak-db-password" | quote -}}
    {{- end -}}
{{- end -}}

{{/*
Support for existing Keycloak secret
*/}}
{{- define "dome-wallet-keycloak.keycloakSecretName" -}}
    {{- if .Values.app.keycloak.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.keycloak.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "%s" (include "dome-wallet-keycloak.fullname" .) | quote -}}
    {{- end -}}
{{- end -}}

{{- define "dome-wallet-keycloak.keycloak-passwordKey" -}}
    {{- if .Values.app.keycloak.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.keycloak.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "%s" "keycloak-password" | quote -}}
    {{- end -}}
{{- end -}}

{{/*
Support for existing mail secret
*/}}
{{- define "keycloak.mail-secretName" -}}
    {{- if .Values.app.keycloak.mail.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.keycloak.mail.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "%s" (include "dome-wallet-keycloak.fullname" .) | quote -}}
    {{- end -}}
{{- end -}}

{{- define "keycloak.mail-userKey" -}}
    {{- if .Values.app.keycloak.mail.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.keycloak.mail.existingSecret.userKey $) -}}
    {{- else -}}
        {{- printf "%s" "mail-username" | quote -}}
    {{- end -}}
{{- end -}}

{{- define "keycloak.mail-passwordKey" -}}
    {{- if .Values.app.keycloak.mail.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.keycloak.mail.existingSecret.passwordKey $) -}}
    {{- else -}}
        {{- printf "%s" "mail-password" | quote -}}
    {{- end -}}
{{- end -}}

{{/*
Internal Server Port
*/}}
{{- define "dome-wallet-keycloak.serverPort" -}}
{{- default 8080 }}
{{- end }}