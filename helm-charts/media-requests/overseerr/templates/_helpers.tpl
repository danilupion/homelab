{{/*
Create Overseerr deployment
*/}}
{{- define "overseerr.deployment" -}}
{{- $lang := default "default" .language -}}
{{- $app := index .Values .Chart.Name }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Chart.Name }}{{- if ne $lang "default" }}-{{ $lang }}{{- end }}-app
  labels:
    app: {{ .Chart.Name }}{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
    language: {{ $lang }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ .Chart.Name }}{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
      language: {{ $lang }}
  template:
    metadata:
      labels:
        app: {{ .Chart.Name }}{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
        language: {{ $lang }}
    spec:
      initContainers:
        - name: create-config-dir
          image: busybox
          securityContext:
            runAsUser: {{ include "service.value" (dict "context" . "prop" "uid") | int }}
            runAsGroup: {{ include "service.value" (dict "context" . "prop" "gid") | int }}
          command: ['sh', '-c', 'mkdir -p /configRoot/{{ .Chart.Name }}{{- if ne $lang "default" }}-{{ $lang }}{{- end }} && chmod 700 /configRoot/{{ .Chart.Name }}{{- if ne $lang "default" }}-{{ $lang }}{{- end }}']
          volumeMounts:
            - name: config-root
              mountPath: /configRoot
      containers:
        - name: {{ .Chart.Name }}{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
          image: "{{ $app.image.repository }}:{{ $app.image.tag }}"
          imagePullPolicy: {{ $app.image.pullPolicy | default "IfNotPresent" }}
          env:
            - name: PUID
              value: "{{ include "service.value" (dict "context" . "prop" "uid") | int }}"
            - name: PGID
              value: "{{ include "service.value" (dict "context" . "prop" "gid") | int }}"
            - name: TZ
              value: {{ include "service.value" (dict "context" . "prop" "tz") | quote }}
          ports:
            {{- range (index .Values .Chart.Name).ports }}
            - containerPort: {{ .port }}
              protocol: {{ default "TCP" .protocol }}
            {{- end }}
          volumeMounts:
            - name: config-root
              mountPath: /config
              subPath: {{ .Chart.Name }}{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
      volumes:
        - name: config-root
          hostPath:
            path: {{ required "A value for paths.configRoot is required" .Values.paths.configRoot }}
{{- end -}}

{{/*
Create Overseerr service
*/}}
{{- define "overseerr.service" -}}
{{- $lang := default "default" .language -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ .Chart.Name }}{{- if ne $lang "default" }}-{{ $lang }}{{- end }}-service
  labels:
    app: {{ .Chart.Name }}{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
    language: {{ $lang }}
spec:
  type: ClusterIP
  selector:
    app: {{ .Chart.Name }}{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
    language: {{ $lang }}
  ports:
    {{- range (index .Values .Chart.Name "ports") }}
    - name: {{ .name }}
      port: {{ .port }}
      targetPort: {{ .targetPort }}
      protocol: {{ default "TCP" .protocol }}
    {{- end }}
{{- end -}}

{{/*
Create Overseerr ingress
*/}}
{{- define "overseerr.ingress" -}}
{{- $lang := default "default" .language -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Chart.Name }}{{- if ne $lang "default" }}-{{ $lang }}{{- end }}-ingress
  labels:
    app: {{ .Chart.Name }}{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
    language: {{ $lang }}
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-cloudflare"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - {{ include "service.subdomain" . }}{{- if ne $lang "default" }}-{{ $lang }}{{- end }}.{{ required "A value for domain is required" .Values.domain }}
      secretName: {{ .Chart.Name }}{{- if ne $lang "default" }}-{{ $lang }}{{- end }}-tls-secret
  rules:
    - host: {{ include "service.subdomain" . }}{{- if ne $lang "default" }}-{{ $lang }}{{- end }}.{{ required "A value for domain is required" .Values.domain }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: {{ .Chart.Name }}{{- if ne $lang "default" }}-{{ $lang }}{{- end }}-service
                port:
                  number: {{ include "utils.portByName" (dict "ports" (index .Values .Chart.Name "ports") "portName" "http") }}
{{- end -}}
