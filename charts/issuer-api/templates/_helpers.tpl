{{/*
Expand the name of the chart.
*/}}
{{- define "issuer-api.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "issuer-api.fullname" -}}
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
{{- define "issuer-api.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "issuer-api.labels" -}}
helm.sh/chart: {{ include "issuer-api.chart" . }}
{{ include "issuer-api.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "issuer-api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "issuer-api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "issuer-api.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "issuer-api.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Support for existing database secret 
*/}}
{{- define "issuer-api.db-secretName" -}}
    {{- if .Values.db.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.db.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "issuer-api-db-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "issuer-api.db-passwordKey" -}}
    {{- if .Values.db.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.db.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "password" -}}
    {{- end -}}
{{- end -}}

{{/*
Support for existing auth server client secret 
*/}}
{{- define "issuer-api.authServerClient-secretName" -}}
    {{- if .Values.app.authServer.client.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.authServer.client.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "issuer-api-auth-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "issuer-api.authServerClient-clientSecretKey" -}}
    {{- if .Values.app.authServer.client.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.authServer.client.existingSecret.clientSecretKey $) -}}
    {{- else -}}
        {{- printf "client-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "issuer-api.authServerClient-passwordKey" -}}
    {{- if .Values.app.authServer.client.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.authServer.client.existingSecret.clientPasswordKey $) -}}
    {{- else -}}
        {{- printf "password" -}}
    {{- end -}}
{{- end -}}

{{/*
Support for existing mail secret 
*/}}
{{- define "issuer-api.mail-secretName" -}}
    {{- if .Values.app.mail.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.mail.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "issuer-api-mail-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "issuer-api.mail-userKey" -}}
    {{- if .Values.app.mail.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.mail.existingSecret.userKey $) -}}
    {{- else -}}
        {{- printf "username" -}}
    {{- end -}}
{{- end -}}

{{- define "issuer-api.mail-passwordKey" -}}
    {{- if .Values.app.mail.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.mail.existingSecret.passwordKey $) -}}
    {{- else -}}
        {{- printf "password" -}}
    {{- end -}}
{{- end -}}

{{/*
Support for existing verifier secret
*/}}
{{- define "issuer-api.verifier-secretName" -}}
    {{- if .Values.app.verifier.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.verifier.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "issuer-api-verifier-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "issuer-api.verifier-vcKey" -}}
    {{- if .Values.app.verifier.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.verifier.existingSecret.vcKey $) -}}
    {{- else -}}
        {{- printf "vc" -}}
    {{- end -}}
{{- end -}}

{{- define "issuer-api.verifier-cryptoPrivateKey" -}}
    {{- if .Values.app.verifier.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.verifier.existingSecret.cryptoPrivateKey $) -}}
    {{- else -}}
        {{- printf "private-key" -}}
    {{- end -}}
{{- end -}}