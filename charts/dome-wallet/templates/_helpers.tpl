{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dome-wallet.fullname" -}}
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

# todo: find a way to avoid hardcoded name
{{/*
Backend service name
*/}}
{{- define "dome-wallet-backend.service.name" -}}
dome-wallet-dome-wallet-backend
{{- end }}

# todo: find a way to avoid hardcoded name
{{/*
Frontend name
*/}}
{{- define "dome-wallet-frontend.service.name" -}}
dome-wallet-dome-wallet-frontend
{{- end }}