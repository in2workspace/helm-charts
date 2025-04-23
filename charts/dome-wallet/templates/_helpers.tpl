{{/*
Create a default fully qualified app name.
*/}}
{{- define "dome-wallet.fullname" -}}
{{- .Chart.Name }}
{{- end }}


{{- define "dome-wallet.url" -}}
{{ .Values.global.domain }}
{{- end }}

{{- define "dome-wallet-backend.service.name" -}}
{{ index .Values "dome-wallet-backend" "fullnameOverride" }}
{{- end }}

{{- define "dome-wallet-frontend.service.name" -}}
{{ index .Values "dome-wallet-frontend" "fullnameOverride" }}
{{- end }}