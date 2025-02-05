{{/*
Expand the name of the chart.
*/}}
{{- define "wallet-api.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "wallet-api.fullname" -}}
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
{{- define "wallet-api.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "wallet-api.labels" -}}
helm.sh/chart: {{ include "wallet-api.chart" . }}
{{ include "wallet-api.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "wallet-api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "wallet-api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "wallet-api.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "wallet-api.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Support for existing database secret 
*/}}
{{- define "wallet-api.clientSecretName" -}}
    {{- if .Values.app.ebsiTest.client.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.ebsiTest.client.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "wallet-api-client-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "wallet-api.client-passwordKey" -}}
    {{- if .Values.app.ebsiTest.client.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.ebsiTest.client.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "client-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "wallet-api.userSecretName" -}}
    {{- if .Values.app.ebsiTest.userData.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.ebsiTest.userData.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "wallet-api-user-password" -}}
    {{- end -}}
{{- end -}}

{{- define "wallet-api.user-passwordKey" -}}
    {{- if .Values.app.ebsiTest.userData.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.ebsiTest.userData.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "user-password" -}}
    {{- end -}}
{{- end -}}

{{- define "wallet-api.vaultTokenSecretName" -}}
    {{- if .Values.app.vault.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.vault.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "wallet-api-token-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "wallet-api.user-tokenKey" -}}
    {{- if .Values.app.vault.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.vault.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "token" -}}
    {{- end -}}
{{- end -}}

{{/*
Support for existing database secret
*/}}
{{- define "wallet-api.db-secretName" -}}
    {{- if .Values.db.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.db.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "wallet-api-db-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "wallet-api.db-passwordKey" -}}
    {{- if .Values.db.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.db.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "password" -}}
    {{- end -}}
{{- end -}}

{{/* Validate that the required values are set when db.externalService is true or false. */}}
{{- define "validateDatabaseConfig" -}}
{{- if .Values.db.externalService }}
  {{/*Cuando externalService es verdadero, validamos los campos*/}}
  {{- if empty .Values.db.host }}
    {{ fail "El valor 'db.host' no puede estar vacío cuando 'db.externalService' está habilitado." }}
  {{- end }}
  {{- if empty .Values.db.name }}
    {{ fail "El valor 'db.name' no puede estar vacío cuando 'db.externalService' está habilitado." }}
  {{- end }}
  {{- if empty .Values.db.schema }}
    {{ fail "El valor 'db.schema' no puede estar vacío cuando 'db.externalService' está habilitado." }}
  {{- end }}
  {{- if empty .Values.db.username }}
    {{ fail "El valor 'db.username' no puede estar vacío cuando 'db.externalService' está habilitado." }}
  {{- end }}
  {{- if empty .Values.db.password }}
    {{ fail "El valor 'db.password' no puede estar vacío cuando 'db.externalService' está habilitado." }}
  {{- end }}
{{- else }}
  {{/* Cuando externalService es falso, validamos que los valores sean específicos */}}
  {{- if ne .Values.db.host "wallet-postgres" }}
    {{ fail "El valor 'db.host' debe ser 'localhost' cuando 'db.externalService' está deshabilitado." }}
  {{- end }}
  {{- if ne .Values.db.port 5432 }}
    {{ fail "El valor 'db.port' debe ser '5432' cuando 'db.externalService' está deshabilitado." }}
  {{- end }}
  {{- if ne .Values.db.name "wallet" }}
    {{ fail "El valor 'db.name' debe ser 'issuer' cuando 'db.externalService' está deshabilitado." }}
  {{- end }}
  {{- if ne .Values.db.schema "wallet" }}
    {{ fail "El valor 'db.schema' debe ser 'public' cuando 'db.externalService' está deshabilitado." }}
  {{- end }}
  {{- if ne .Values.db.username "postgres" }}
    {{ fail "El valor 'db.username' debe ser 'postgres' cuando 'db.externalService' está deshabilitado." }}
  {{- end }}
  {{- if empty .Values.db.password }}
    {{ fail "El valor 'db.password' no puede estar vacío cuando 'db.externalService' está deshabilitado." }}
  {{- end }}
{{- end }}
{{- end }}