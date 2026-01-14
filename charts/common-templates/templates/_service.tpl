{{- define "gallery.service" -}}
{{ $serviceName := .Values.serviceName -}}
{{ $containerPort := .Values.containerPort -}}

{{- with .Values.service -}}
{{- if .create }}
apiVersion: v1
kind: Service
metadata:
  name: {{ $serviceName }}
  namespace: {{ $.Release.Namespace }}
  labels:
    {{- include "..labels" $ | nindent 4 }}
    component: {{ $serviceName }}
spec:
  type: {{ .serviceType | default "ClusterIP" }}
  {{- if .headless }}
  clusterIP: None
  {{- end }}
  selector:
    {{- include "..selectorLabels" $ | nindent 4 }}
    component: {{ $serviceName }}
  ports:
    {{- if .servicePorts }}
    {{- toYaml .servicePorts | nindent 4 }}
    {{- else }}
    - port: {{ .servicePort | default $containerPort }}
      targetPort: {{ .targetPort | default $containerPort }}
      protocol: TCP
      name: http
     {{- end }}
{{- end }}
{{- end -}}
{{- end -}}