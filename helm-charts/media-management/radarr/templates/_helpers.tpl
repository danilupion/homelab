{{/*
Create Radarr deployment
*/}}
{{- define "radarr.deployment" -}}
{{- $lang := default "default" .language -}}  # Set $lang to "default" if .language is not set
apiVersion: apps/v1
kind: Deployment
metadata:
  name: radarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}-app
  labels:
    app: radarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
    language: {{ $lang }}  # Add the language label
spec:
  replicas: 1
  selector:
    matchLabels:
      app: radarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
      language: {{ $lang }}  # Ensure the selector includes the language label
  template:
    metadata:
      labels:
        app: radarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
        language: {{ $lang }}  # Pod template labels also include the language
    spec:
      containers:
        - name: radarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
          image: lscr.io/linuxserver/radarr:latest
          env:
            - name: PUID
              value: {{ required "A value for radarr.puid is required" .Values.radarr.puid | quote }}
            - name: PGID
              value: {{ required "A value for radarr.guid is required" .Values.radarr.guid | quote }}
            - name: TZ
              value: {{ required "A value for tz is required" .Values.tz | quote }}
          ports:
            {{- range .Values.radarr.ports }}
            - containerPort: {{ .port }}
              protocol: {{ default "TCP" .protocol }}
            {{- end }}
          volumeMounts:
            - name: config
              mountPath: /config
            {{- include "utils.volumeMounts" (dict "mediaPaths" .Values.paths.mediaPaths "mediaTypes" .Values.radarr.mediaTypes) | nindent 12 }}
      volumes:
        - name: config
          hostPath:
            path: {{ required "A value for paths.configRoot is required" .Values.paths.configRoot }}/radarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
        {{- include "utils.volumes" (dict "mediaPaths" .Values.paths.mediaPaths "mediaTypes" .Values.radarr.mediaTypes "suffix" .language) | nindent 8 }}
{{- end -}}

{{/*
Create Radarr service
*/}}
{{- define "radarr.service" -}}
{{- $lang := default "default" .language -}}  # Set $lang to "default" if .language is not set
apiVersion: v1
kind: Service
metadata:
  name: radarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}-service
  labels:
    app: radarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
    language: {{ $lang }}  # Add the language labelspec:
spec:
  type: ClusterIP
  selector:
    app: radarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
    language: {{ $lang }}  # Ensure the selector includes the language label
  ports:
    {{- range .Values.radarr.ports }}
    - name: {{ .name }}
      port: {{ .port }}
      targetPort: {{ .targetPort }}
      protocol: {{ default "TCP" .protocol }}
    {{- end }}
{{- end -}}

{{/*
Create Radarr ingress
*/}}
{{- define "radarr.ingress" -}}
{{- $lang := default "default" .language -}}  # Set $lang to "default" if .language is not set
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: radarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}-ingress
  labels:
    app: radarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
    language: {{ $lang }}  # Add the language label
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-cloudflare"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - radarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}.{{ required "A value for domain is required" .Values.domain }}
      secretName: radarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}-tls-secret
  rules:
    - host: radarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}.{{ required "A value for domain is required" .Values.domain }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: radarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}-service
                port:
                  number: {{ include "utils.portByName" (dict "ports" .Values.radarr.ports "portName" "http") }}
{{- end -}}
