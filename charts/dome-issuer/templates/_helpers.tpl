{{- define "issuer.fullname" -}}
{{ .Values.global.tenantName }}-issuer
{{- end}}

{{- define "issuer.url" -}}
{{ .Values.global.domain }}
{{- end }}


{{- define "issuer-backend.service.name" -}}
issuer-api
{{- end }}

{{- define "issuer-frontend.service.name" -}}
{{ .Values.global.tenantName }}-issuer-{{ .Values.global.tenantName }}-issuer-frontend
{{- end }}
