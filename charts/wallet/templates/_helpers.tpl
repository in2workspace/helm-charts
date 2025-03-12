{{- define "wallet.fullname" -}}
tenant-{{ .Values.global.tenantName }}-wallet
{{- end}}

{{- define "wallet.application.domain" -}}
{{- if eq .Values.global.environment "prod" -}}
    wallet.{{ .Values.global.tenantName }}.{{ .Values.global.externalDomain }}
{{- else -}}
    wallet-{{ .Values.global.environment }}.{{ .Values.global.tenantName }}.{{ .Values.global.externalDomain }}
{{- end }}
{{- end }}

{{- define "wallet-backend.service.name" -}}
tenant-{{ .Values.global.tenantName }}-wallet-wallet-backend
{{- end }}

{{- define "wallet-frontend.service.name" -}}
tenant-{{ .Values.global.tenantName }}-wallet-wallet-frontend
{{- end }}
