{{- define "wallet.domain" -}}
{{- if eq .Values.global.environment "prod" -}}
wallet.{{ .Values.global.tenantName }}.{{ .Values.global.externalDomain }}
{{- else -}}
wallet-{{ .Values.global.environment }}.{{ .Values.global.tenantName }}.{{ .Values.global.externalDomain }}
{{- end }}
{{- end }}
