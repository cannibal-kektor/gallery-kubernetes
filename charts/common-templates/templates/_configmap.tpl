{{- define "gallery.configmap" -}}

{{- $files := .Files -}}
{{- with .Values -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "..fullname" $ }}-config
  labels:
    {{- include "..labels" $ | nindent 4 }}
    component: {{ .serviceName }}
data:
  {{- if .variables }}
  {{- tpl (toYaml .variables) $ | nindent 2}}
  {{- end }}
  {{- range .files }}
  {{ .dest }}: |
    {{- tpl ($files.Get .src) $ | nindent 4 }}
  {{- end }}
{{- end }}
{{- end -}}