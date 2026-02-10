{{/*
Create a default fully qualified app name.
*/}}
{{- define "eudistack-wallet.fullname" -}}
{{- .Chart.Name }}
{{- end }}


{{- define "eudistack-wallet.url" -}}
{{ .Values.global.domain }}
{{- end }}

{{- define "eudistack-wallet-enterprise-backend.service.name" -}}
{{ index .Values "eudistack-wallet-enterprise-backend" "fullnameOverride" }}
{{- end }}

{{- define "eudistack-wallet-core-frontend.service.name" -}}
{{ index .Values "eudistack-wallet-core-frontend" "fullnameOverride" }}
{{- end }}