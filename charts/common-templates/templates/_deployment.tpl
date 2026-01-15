{{- define "gallery.deployment" -}}
{{- with .Values -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name:  {{ include "..fullname" $ }}
  namespace: {{ $.Release.Namespace }}
  labels:
    {{- include "..labels" $ | nindent 4 }}
    component: {{ .serviceName }}
spec:
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
          ports:
            - containerPort: {{ .containerPort | default 8080 }}

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

          {{- if or .env .redis .dbConnection }}
          env:
            {{- if .env }}
            {{- tpl (toYaml .env) $ | nindent 12 }}
            {{- end }}
            {{- if .redis }}
            - name: REDIS_USER
              valueFrom:
                secretKeyRef:
                  name: '{{ $.Release.Name }}-{{ $.Values.secret.redis.secretName }}'
                  key: '{{ $.Values.secret.redis.userKey }}'
            - name: REDIS_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: '{{ $.Release.Name }}-{{ $.Values.secret.redis.secretName }}'
                  key: '{{ $.Values.secret.redis.passwordKey }}'
            {{- end }}
            {{- if .dbConnection }}
            - name: {{ .dbConnection.user }}
              valueFrom:
                secretKeyRef:
                  name: '{{ $.Release.Name }}-{{ $.Values.secret.db.secretName }}'
                  key: '{{ $.Values.secret.db.userKey }}'
            - name: {{ .dbConnection.password }}
              valueFrom:
                secretKeyRef:
                  name: '{{ $.Release.Name }}-{{ $.Values.secret.db.secretName }}'
                  key: '{{ $.Values.secret.db.passwordKey }}'
            {{- end }}
            {{- if .awsConnection }}
            - name: AWS_ACCESS_KEY
              valueFrom:
                secretKeyRef:
                  name: '{{ $.Release.Name }}-{{ $.Values.secret.aws.secretName }}'
                  key: '{{ $.Values.secret.aws.accessKey }}'
            - name: AWS_SECRET_KEY
              valueFrom:
                secretKeyRef:
                  name: '{{ $.Release.Name }}-{{ $.Values.secret.aws.secretName }}'
                  key: '{{ $.Values.secret.aws.secretKey }}'
            {{- end }}
          {{- end }}

          {{- if .volumeMounts }}
          volumeMounts:
            {{- toYaml .volumeMounts | nindent 12 }}
          {{- end }}

          {{- if .resources }}
          resources:
            {{- toYaml .resources | nindent 12 }}
          {{- end }}

          {{- with .probe }}
          {{- if .enabled }}
          {{- $liveness := .liveness | default dict }}
          {{- $readiness := .readiness | default dict }}
          livenessProbe:
            httpGet:
              path: {{ $liveness.path | default "/actuator/health/liveness" }}
              port: {{ $.Values.containerPort | default 8080 }}
              scheme: {{ .scheme | default "HTTP" }}
            initialDelaySeconds: {{ $liveness.initialDelaySeconds | default 45 }}
            periodSeconds: {{ $liveness.periodSeconds | default 15 }}
            timeoutSeconds: {{ $liveness.timeoutSeconds | default 5 }}
          readinessProbe:
            httpGet:
              path: {{ $readiness.path | default "/actuator/health/readiness" }}
              port: {{ $.Values.containerPort | default 8080 }}
              scheme: {{ .scheme | default "HTTP" }}
            initialDelaySeconds: {{ $readiness.initialDelaySeconds | default 20 }}
            periodSeconds: {{ $readiness.periodSeconds | default 10 }}
            timeoutSeconds: {{ $readiness.timeoutSeconds | default 3 }}
          {{- end }}
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
{{- end }}
{{- end }}