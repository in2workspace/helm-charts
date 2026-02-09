{{/*
Create a default fully qualified app name.
*/}}
{{- define "eudistack-issuer.fullname" -}}
{{- .Chart.Name }}
{{- end }}

{{- define "eudistack-issuer.url" -}}
{{ .Values.global.domain }}
{{- end }}


{{- define "eudistack-issuer-core-backend.service.name" -}}
{{ index .Values "eudistack-issuer-core-backend" "fullnameOverride" }}
{{- end }}

{{- define "eudistack-issuer-enterprise-backend.service.name" -}}
{{ index .Values "eudistack-issuer-enterprise-backend" "fullnameOverride" }}
{{- end }}

{{- define "eudistack-issuer-frontend.service.name" -}}
{{ index .Values "eudistack-issuer-frontend" "fullnameOverride" }}
{{- end }}

