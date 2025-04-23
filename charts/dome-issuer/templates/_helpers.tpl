{{/*
Create a default fully qualified app name.
*/}}
{{- define "dome-issuer.fullname" -}}
{{- .Chart.Name }}
{{- end }}

{{- define "dome-issuer.url" -}}
{{ .Values.global.domain }}
{{- end }}


{{- define "dome-issuer-backend.service.name" -}}
{{ index .Values "dome-issuer-backend" "fullnameOverride" }}
{{- end }}

{{- define "dome-issuer-frontend.service.name" -}}
{{ index .Values "dome-wallet-frontend" "fullnameOverride" }}
{{- end }}
