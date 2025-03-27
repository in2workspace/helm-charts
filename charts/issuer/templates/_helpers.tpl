{{- define "issuer.fullname" -}}
tenant-{{ .Values.global.tenantName }}-issuer
{{- end}}

{{- define "issuer.application.domain" -}}
{{- if eq .Values.global.environment "prod" -}}
    issuer.{{ .Values.global.tenantName }}.{{ .Values.global.externalDomain }}
{{- else -}}
    issuer-{{ .Values.global.environment }}.{{ .Values.global.tenantName }}.{{ .Values.global.externalDomain }}
{{- end }}
{{- end }}

{{- define "issuer-backend.service.name" -}}
tenant-{{ .Values.global.tenantName }}-issuer-issuer-backend
{{- end }}

{{- define "issuer-frontend.service.name" -}}
tenant-{{ .Values.global.tenantName }}-issuer-issuer-frontend
{{- end }}

{{- define "issuer-dss.service.name" -}}
tenant-{{ .Values.global.tenantName }}-issuer-issuer-dss
{{- end }}
