{{/*
Expand the name of the chart.
*/}}
{{- define "issuer-keycloak-plugin.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "issuer-keycloak-plugin.fullname" -}}
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
{{- define "issuer-keycloak-plugin.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "issuer-keycloak-plugin.labels" -}}
helm.sh/chart: {{ include "issuer-keycloak-plugin.chart" . }}
{{ include "issuer-keycloak-plugin.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "issuer-keycloak-plugin.selectorLabels" -}}
app.kubernetes.io/name: {{ include "issuer-keycloak-plugin.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "issuer-keycloak-plugin.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "issuer-keycloak-plugin.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Support for existing keycloak admin secret 
*/}}
{{- define "keycloak.secretName.admin" -}}
    {{- if .Values.keycloak.admin.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.keycloak.admin.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "%s" (include "issuer-api.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{- define "keycloak.passwordKey.admin" -}}
    {{- if .Values.keycloak.admin.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.keycloak.admin.existingSecret.passwordKey $) -}}
    {{- else -}}
        {{- printf "keycloak-admin-password" -}}
    {{- end -}}
{{- end -}}

{{/*
Support for existing keycloak https secret 
*/}}
{{- define "keycloak.secretName.https" -}}
    {{- if .Values.keycloak.https.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.keycloak.https.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "%s" (include "issuer-api.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{- define "keycloak.trustStorePasswordKey.https" -}}
    {{- if .Values.keycloak.https.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.keycloak.https.existingSecret.trustStorePasswordKey $) -}}
    {{- else -}}
        {{- printf "keycloak-truststore-password" -}}
    {{- end -}}
{{- end -}}

{{/*
Support for existing keycloak db secret 
*/}}
{{- define "keycloak.secretName.db" -}}
    {{- if .Values.keycloak.db.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.keycloak.db.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "%s" (include "issuer-api.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{- define "keycloak.passwordKey.db" -}}
    {{- if .Values.keycloak.db.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.keycloak.db.existingSecret.passwordKey $) -}}
    {{- else -}}
        {{- printf "keycloak-db-password" -}}
    {{- end -}}
{{- end -}}
