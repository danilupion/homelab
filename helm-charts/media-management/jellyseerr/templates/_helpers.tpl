{{/*
Create Jellyseerr deployment
*/}}
{{- define "jellyseerr.deployment" -}}
{{- $lang := default "default" .language -}}  # Set $lang to "default" if .language is not set
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jellyseerr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}-app
  labels:
    app: jellyseerr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
    language: {{ $lang }}  # Add the language label
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jellyseerr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
      language: {{ $lang }}  # Ensure the selector includes the language label
  template:
    metadata:
      labels:
        app: jellyseerr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
        language: {{ $lang }}  # Pod template labels also include the language
    spec:
      initContainers:
        - name: adjust-jellyseerr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}-permissions
          image: busybox
          command: ['sh', '-c', 'chown -R {{ required "A value for jellyseerr.puid is required" .Values.jellyseerr.puid }}:{{ required "A value for jellyseerr.guid is required" .Values.jellyseerr.guid }} {{ required "A value for paths.configRoot is required" .Values.paths.configRoot }}/jellyseerr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}']
          volumeMounts:
            - name: config
              mountPath: {{ required "A value for paths.configRoot is required" .Values.paths.configRoot }}/jellyseerr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
      containers:
        - name: jellyseerr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
          image: fallenbagel/jellyseerr:latest
          securityContext:
            runAsUser: {{ required "A value for jellyseerr.puid is required" .Values.jellyseerr.puid }}
            runAsGroup: {{ required "A value for jellyseerr.guid is required" .Values.jellyseerr.guid }}
          env:
            - name: TZ
              value: {{ required "A value for tz is required" .Values.tz | quote }}
          ports:
            {{- range .Values.jellyseerr.ports }}
            - containerPort: {{ .port }}
              protocol: {{ default "TCP" .protocol }}
            {{- end }}
          volumeMounts:
            - name: config
              mountPath: /app/config
      volumes:
        - name: config
          hostPath:
            path: {{ required "A value for paths.configRoot is required" .Values.paths.configRoot }}/jellyseerr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
{{- end -}}

{{/*
Create Jellyseerr service
*/}}
{{- define "jellyseerr.service" -}}
{{- $lang := default "default" .language -}}  # Set $lang to "default" if .language is not set
apiVersion: v1
kind: Service
metadata:
  name: jellyseerr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}-service
  labels:
    app: jellyseerr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
    language: {{ $lang }}  # Add the language labelspec:
spec:
  type: ClusterIP
  selector:
    app: jellyseerr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
    language: {{ $lang }}  # Ensure the selector includes the language label
  ports:
    {{- range .Values.jellyseerr.ports }}
    - name: {{ .name }}
      port: {{ .port }}
      targetPort: {{ .targetPort }}
      protocol: {{ default "TCP" .protocol }}
    {{- end }}
{{- end -}}

{{/*
Create Jellyseerr ingress
*/}}
{{- define "jellyseerr.ingress" -}}
{{- $lang := default "default" .language -}}  # Set $lang to "default" if .language is not set
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: jellyseerr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}-ingress
  labels:
    app: jellyseerr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
    language: {{ $lang }}  # Add the language label
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-cloudflare"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - jellyseerr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}.{{ required "A value for domain is required" .Values.domain }}
      secretName: jellyseerr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}-tls-secret
  rules:
    - host: jellyseerr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}.{{ required "A value for domain is required" .Values.domain }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: jellyseerr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}-service
                port:
                  number: {{ include "utils.portByName" (dict "ports" .Values.jellyseerr.ports "portName" "http") }}
{{- end -}}
