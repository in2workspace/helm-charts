{{/*
Support for existing remote-signature-secret
*/}}

{{- define "eudistack-issuer-enterprise-backend.remoteSignature-secretName" -}}
{{- if .Values.app.remoteSignature.existingSecret.enabled -}}
  {{- if .Values.app.remoteSignature.existingSecret.name -}}
    {{- .Values.app.remoteSignature.existingSecret.name -}}
  {{- else -}}
    {{- fail "remoteSignature.existingSecret.enabled=true but no existingSecret.name provided" -}}
  {{- end -}}
{{- else -}}
  {{- include "eudistack-issuer-enterprise-backend.fullname" . -}}
{{- end -}}
{{- end -}}

{{- define "eudistack-issuer-enterprise-backend.remoteSignature-clientId" -}}
remote-signature-client-id
{{- end -}}

{{- define "eudistack-issuer-enterprise-backend.remoteSignature-clientSecret" -}}
remote-signature-client-secret
{{- end -}}

{{- define "eudistack-issuer-enterprise-backend.remoteSignature-credentialId" -}}
remote-signature-credential-id
{{- end -}}

{{- define "eudistack-issuer-enterprise-backend.remoteSignature-credentialPassword" -}}
remote-signature-credential-password
{{- end -}}