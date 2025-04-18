{{/*
Expand the name of the chart.
*/}}
{{- define "dome-issuer-api.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dome-issuer-api.fullname" -}}
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
{{- define "dome-issuer-api.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "dome-issuer-api.labels" -}}
helm.sh/chart: {{ include "dome-issuer-api.chart" . }}
{{ include "dome-issuer-api.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dome-issuer-api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dome-issuer-api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "dome-issuer-api.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "dome-issuer-api.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Support for existing database secret
*/}}
{{- define "dome-issuer-api.db-secretName" -}}
    {{- if .Values.db.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.db.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "issuer-api-db-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "dome-issuer-api.db-passwordKey" -}}
    {{- if .Values.db.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.db.existingSecret.key $) -}}
    {{- else -}}
        {{- printf "password" -}}
    {{- end -}}
{{- end -}}

{{/*
Support for existing auth server client secret
*/}}
{{- define "dome-issuer-api.authServerClient-secretName" -}}
    {{- if .Values.app.authServer.client.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.authServer.client.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "issuer-api-auth-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "dome-issuer-api.authServerClient-clientSecretKey" -}}
    {{- if .Values.app.authServer.client.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.authServer.client.existingSecret.clientSecretKey $) -}}
    {{- else -}}
        {{- printf "client-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "dome-issuer-api.authServerClient-passwordKey" -}}
    {{- if .Values.app.authServer.client.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.authServer.client.existingSecret.clientPasswordKey $) -}}
    {{- else -}}
        {{- printf "password" -}}
    {{- end -}}
{{- end -}}

{{/*
Support for existing mail secret
*/}}
{{- define "dome-issuer-api.mail-secretName" -}}
    {{- if .Values.app.mail.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.mail.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "issuer-api-mail-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "dome-issuer-api.mail-userKey" -}}
    {{- if .Values.app.mail.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.mail.existingSecret.userKey $) -}}
    {{- else -}}
        {{- printf "username" -}}
    {{- end -}}
{{- end -}}

{{- define "dome-issuer-api.mail-passwordKey" -}}
    {{- if .Values.app.mail.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.mail.existingSecret.passwordKey $) -}}
    {{- else -}}
        {{- printf "password" -}}
    {{- end -}}
{{- end -}}

{{/*
Support for existing issuer identity secret
*/}}
{{- define "dome-issuer-api.issuerIdentity-secretName" -}}
    {{- if .Values.app.issuerIdentity.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.issuerIdentity.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "issuer-api-issuer-identity-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "dome-issuer-api.issuerIdentity-privateKey" -}}
    {{- if .Values.app.issuerIdentity.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.issuerIdentity.existingSecret.privateKey $) -}}
    {{- else -}}
        {{- printf "private-key" -}}
    {{- end -}}
{{- end -}}

{{- define "dome-issuer-api.issuerIdentity-vc" -}}
    {{- if .Values.app.issuerIdentity.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.issuerIdentity.existingSecret.vc $) -}}
    {{- else -}}
        {{- printf "vc" -}}
    {{- end -}}
{{- end -}}

{{- define "dome-issuer-api.issuerIdentity-credentialDidKey" -}}
    {{- if .Values.app.issuerIdentity.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.issuerIdentity.existingSecret.credentialDidKey $) -}}
    {{- else -}}
        {{- printf "credential-did-key" -}}
    {{- end -}}
{{- end -}}

{{/*
Support for existing default signer secret
*/}}
{{- define "dome-issuer-api.defaultSigner-secretName" -}}
    {{- if .Values.app.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.defaultSigner.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "issuer-api-default-signer-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "dome-issuer-api.defaultSigner-commonName" -}}
    {{- if .Values.app.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.defaultSigner.existingSecret.commonName $) -}}
    {{- else -}}
        {{- printf "common-name" -}}
    {{- end -}}
{{- end -}}

{{- define "dome-issuer-api.defaultSigner-organization" -}}
    {{- if .Values.app.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.defaultSigner.existingSecret.organization $) -}}
    {{- else -}}
        {{- printf "organization" -}}
    {{- end -}}
{{- end -}}

{{- define "dome-issuer-api.defaultSigner-country" -}}
    {{- if .Values.app.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.defaultSigner.existingSecret.country $) -}}
    {{- else -}}
        {{- printf "country" -}}
    {{- end -}}
{{- end -}}

{{- define "dome-issuer-api.defaultSigner-email" -}}
    {{- if .Values.app.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.defaultSigner.existingSecret.email $) -}}
    {{- else -}}
        {{- printf "email" -}}
    {{- end -}}
{{- end -}}

{{- define "dome-issuer-api.defaultSigner-organizationIdentifier" -}}
    {{- if .Values.app.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.defaultSigner.existingSecret.organizationIdentifier $) -}}
    {{- else -}}
        {{- printf "organization-identifier" -}}
    {{- end -}}
{{- end -}}

{{- define "dome-issuer-api.defaultSigner-serialNumber" -}}
    {{- if .Values.app.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.defaultSigner.existingSecret.serialNumber $) -}}
    {{- else -}}
        {{- printf "serial-number" -}}
    {{- end -}}
{{- end -}}

{{/*
Support for existing remote-signature-secret
*/}}

{{- define "dome-issuer-api.remoteSignature-secretName" -}}
    {{- if .Values.app.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.remoteSignature.existingSecret.name $) -}}
    {{- else -}}
        {{- printf "issuer-api-remote-signature-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "dome-issuer-api.remoteSignature-clientId" -}}
    {{- if .Values.app.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.remoteSignature.existingSecret.clientId $) -}}
    {{- else -}}
        {{- printf "client-id" -}}
    {{- end -}}
{{- end -}}

{{- define "dome-issuer-api.remoteSignature-clientSecret" -}}
    {{- if .Values.app.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.remoteSignature.existingSecret.clientSecret $) -}}
    {{- else -}}
        {{- printf "client-secret" -}}
    {{- end -}}
{{- end -}}

{{- define "dome-issuer-api.remoteSignature-credentialId" -}}
    {{- if .Values.app.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.remoteSignature.existingSecret.credentialId $) -}}
    {{- else -}}
        {{- printf "credential-id" -}}
    {{- end -}}
{{- end -}}

{{- define "dome-issuer-api.remoteSignature-credentialPassword" -}}
    {{- if .Values.app.defaultSigner.existingSecret.enabled -}}
        {{- printf "%s" (tpl .Values.app.remoteSignature.existingSecret.credentialPassword $) -}}
    {{- else -}}
        {{- printf "credential-password" -}}
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
  {{- if ne .Values.db.host "issuer-postgres" }}
    {{ fail "El valor 'db.host' debe ser 'localhost' cuando 'db.externalService' está deshabilitado." }}
  {{- end }}
  {{- if ne .Values.db.port 5432 }}
    {{ fail "El valor 'db.port' debe ser '5432' cuando 'db.externalService' está deshabilitado." }}
  {{- end }}
  {{- if ne .Values.db.name "issuer" }}
    {{ fail "El valor 'db.name' debe ser 'issuer' cuando 'db.externalService' está deshabilitado." }}
  {{- end }}
  {{- if ne .Values.db.schema "public" }}
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
