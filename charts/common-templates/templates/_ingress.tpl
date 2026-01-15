{{- define "gallery.ingress" -}}
{{- $root := .root -}}
{{- $context := .context -}}
{{- with $context -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "..fullname" $root }}-{{ .name | default "ingress" }}
  namespace: {{ $root.Release.Namespace }}
  {{- if .annotations }}
  annotations:
    {{- toYaml .annotations | nindent 4 }}
  {{- end }}
spec:
  ingressClassName: {{ .className | default "nginx" }}
  rules:
    {{- range .rules }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType | default "Prefix" }}
            backend:
              service:
                name: {{ .serviceName }}
                port:
                  number: {{ .port }}
          {{- end }}
    {{- end }}
{{- end }}
{{- end }}