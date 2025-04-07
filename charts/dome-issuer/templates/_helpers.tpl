{{- define "issuer.fullname" -}}
dome-issuer
{{- end}}

{{- define "issuer.url" -}}
{{ .Values.global.domain }}
{{- end }}


{{- define "issuer-backend.service.name" -}}
dome-issuer-api
{{- end }}

{{- define "issuer-frontend.service.name" -}}
dome-issuer-frontend
{{- end }}
