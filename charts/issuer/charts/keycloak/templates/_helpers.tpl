{{/*
Expand the name of the chart.
*/}}
{{- define "keycloak.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "keycloak.fullname" -}}
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
{{- define "keycloak.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "keycloak.labels" -}}
helm.sh/chart: {{ include "keycloak.chart" . }}
{{ include "keycloak.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "keycloak.selectorLabels" -}}
app.kubernetes.io/name: {{ include "keycloak.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "keycloak.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "keycloak.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Support for existing keycloak admin secret 
*/}}
{{- define "keycloak.admin-secretName" -}}
    {{- if .Values.keycloak.admin.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.keycloak.admin.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "keycloak-admin-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "keycloak.admin-passwordKey" -}}
    {{- if .Values.keycloak.admin.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.keycloak.admin.existingSecret.passwordKey $) -}}
    {{- else -}}
        {{- printf "password" -}}
    {{- end -}}
{{- end -}}

{{/*
Support for existing keycloak https secret 
*/}}
{{- define "keycloak.https-secretName" -}}
    {{- if .Values.keycloak.https.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.keycloak.https.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "keycloak-trust-store-secrets" -}}
    {{- end -}}
{{- end -}}

{{- define "keycloak.https-trustStorePasswordKey" -}}
    {{- if .Values.keycloak.https.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.keycloak.https.existingSecret.trustStorePasswordKey $) -}}
    {{- else -}}
        {{- printf "trust-store-password" -}}
    {{- end -}}
{{- end -}}

{{/*
Support for existing keycloak db secret 
*/}}
{{- define "keycloak.db-secretName" -}}
    {{- if .Values.keycloak.db.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.keycloak.db.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "keycloak-db-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "keycloak.db-passwordKey" -}}
    {{- if .Values.keycloak.db.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.keycloak.db.existingSecret.passwordKey $) -}}
    {{- else -}}
        {{- printf "password" -}}
    {{- end -}}
{{- end -}}

{{/*
Support for existing mail secret
*/}}
{{- define "keycloak.mail-secretName" -}}
    {{- if .Values.keycloak.mail.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.keycloak.mail.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "keycloak-mail-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "keycloak.mail-userKey" -}}
    {{- if .Values.keycloak.mail.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.keycloak.mail.existingSecret.userKey $) -}}
    {{- else -}}
        {{- printf "username" -}}
    {{- end -}}
{{- end -}}

{{- define "keycloak.mail-passwordKey" -}}
    {{- if .Values.keycloak.mail.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.keycloak.mail.existingSecret.passwordKey $) -}}
    {{- else -}}
        {{- printf "password" -}}
    {{- end -}}
{{- end -}}