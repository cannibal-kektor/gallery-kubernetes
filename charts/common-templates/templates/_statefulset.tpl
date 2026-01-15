{{- define "gallery.statefulset" -}}
{{- with .Values -}}
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name:  {{ include "..fullname" $ }}
  labels:
    {{- include "..labels" $ | nindent 4 }}
    component: {{ .serviceName }}
spec:
  serviceName: {{ .serviceName  }}
  replicas: {{ .replicaCount | default 1 }}
  selector:
    matchLabels:
      {{- include "..selectorLabels" $ | nindent 6 }}
      component: {{ .serviceName }}
  template:
    metadata:
      labels:
        {{- include "..labels" $ | nindent 8 }}
        component: {{ .serviceName }}
      annotations:
        checksum/config: {{ toYaml .Values | sha256sum }}
    spec:
      containers:
        - name: {{ .serviceName }}
          image: "{{ .image.repository }}:{{ .image.tag | default "latest" }}"

          {{- if .containerPorts }}
          ports:
            {{- toYaml .containerPorts | nindent 12 }}
          {{- else if .containerPort }}
          ports:
            - containerPort: {{ .containerPort }}
          {{- end }}

          {{- if or .envFrom .variables }}
          envFrom:
            {{- if .variables }}
            - configMapRef:
                name: {{ include "..fullname" $ }}-config
            {{- end }}
            {{- if .envFrom }}
            {{- toYaml .envFrom | nindent 12 }}
            {{- end }}
          {{- end }}

          {{- if .env }}
          env:
            {{- tpl (toYaml .env) $ | nindent 12 }}
          {{- end }}

          {{- if or .storage .volumeMounts }}
          volumeMounts:
            {{- if .storage }}
            - name: {{ .storage.name }}
              mountPath: {{ .storage.path }}
            {{- end}}
            {{- if .volumeMounts }}
            {{- toYaml .volumeMounts | nindent 12 }}
            {{- end}}
          {{- end }}

          {{- if .command }}
          command: {{ toYaml .command | nindent 10 }}
          {{- end }}

          {{- with .probe }}
          {{- if .liveness }}
          livenessProbe:
            {{- toYaml .liveness.livenessProbe | nindent 12 }}
            initialDelaySeconds: {{ .liveness.initialDelaySeconds | default 20 }}
            periodSeconds: {{ .liveness.periodSeconds | default 10 }}
            timeoutSeconds: {{ .liveness.timeoutSeconds | default 3 }}
          {{- end }}

          {{- if .readiness }}
          readinessProbe:
            {{- toYaml .readiness.readinessProbe | nindent 12 }}
            initialDelaySeconds: {{ .readiness.initialDelaySeconds | default 20 }}
            periodSeconds: {{ .readiness.periodSeconds | default 10 }}
            timeoutSeconds: {{ .readiness.timeoutSeconds | default 3 }}
          {{- end }}
          {{- end }}

          {{- if .resources }}
          resources:
            {{- toYaml .resources | nindent 12 }}
          {{- end }}

      {{- if .volumes }}
      volumes:
        {{- range .volumes }}
        {{- if .configMap }}
        - name: {{ .name }}
          configMap:
            name: {{ include "..fullname" $ }}-{{ .configMap.name }}
            defaultMode: {{ .configMap.defaultMode | default 0755 }}
            {{- if .configMap.items }}
            items:
            {{- toYaml .configMap.items | nindent 12 }}
            {{- end }}
        {{- else }}
        - {{ tpl (toYaml .) $ | nindent 10 | trim }}
        {{- end }}
        {{- end }}
      {{- end }}

  {{- if .storage }}
  volumeClaimTemplates:
    - metadata:
        name: {{ .storage.name }}
      spec:
        accessModes: [ {{ .storage.accessMode | default "ReadWriteOnce" | quote }} ]
        resources:
          requests:
            storage: {{ .storage.size | default "2Gi" }}
  {{- end }}
{{- end }}
{{- end -}}