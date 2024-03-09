{{/*
Create Sonarr deployment
*/}}
{{- define "sonarr.deployment" -}}
{{- $lang := default "default" .language -}}  # Set $lang to "default" if .language is not set
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sonarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}-app
  labels:
    app: sonarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
    language: {{ $lang }}  # Add the language label
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sonarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
      language: {{ $lang }}  # Ensure the selector includes the language label
  template:
    metadata:
      labels:
        app: sonarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
        language: {{ $lang }}  # Pod template labels also include the language
    spec:
      containers:
        - name: sonarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
          image: lscr.io/linuxserver/sonarr:latest
          env:
            - name: PUID
              value: {{ required "A value for sonarr.puid is required" .Values.sonarr.puid | quote }}
            - name: PGID
              value: {{ required "A value for sonarr.guid is required" .Values.sonarr.guid | quote }}
            - name: TZ
              value: {{ required "A value for tz is required" .Values.tz | quote }}
          ports:
            {{- range .Values.sonarr.ports }}
            - containerPort: {{ .port }}
              protocol: {{ default "TCP" .protocol }}
            {{- end }}
          volumeMounts:
            - name: config
              mountPath: /config
            {{- include "utils.volumeMounts" (dict "mediaPaths" .Values.paths.mediaPaths "mediaTypes" .Values.sonarr.mediaTypes) | nindent 12 }}
      volumes:
        - name: config
          hostPath:
            path: {{ required "A value for paths.configRoot is required" .Values.paths.configRoot }}/sonarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
        {{- include "utils.volumes" (dict "mediaPaths" .Values.paths.mediaPaths "mediaTypes" .Values.sonarr.mediaTypes "suffix" .language) | nindent 8 }}
{{- end -}}

{{/*
Create Sonarr service
*/}}
{{- define "sonarr.service" -}}
{{- $lang := default "default" .language -}}  # Set $lang to "default" if .language is not set
apiVersion: v1
kind: Service
metadata:
  name: sonarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}-service
  labels:
    app: sonarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
    language: {{ $lang }}  # Add the language labelspec:
spec:
  type: ClusterIP
  selector:
    app: sonarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
    language: {{ $lang }}  # Ensure the selector includes the language label
  ports:
    {{- range .Values.sonarr.ports }}
    - name: {{ .name }}
      port: {{ .port }}
      targetPort: {{ .targetPort }}
      protocol: {{ default "TCP" .protocol }}
    {{- end }}
{{- end -}}

{{/*
Create Sonarr ingress
*/}}
{{- define "sonarr.ingress" -}}
{{- $lang := default "default" .language -}}  # Set $lang to "default" if .language is not set
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sonarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}-ingress
  labels:
    app: sonarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}
    language: {{ $lang }}  # Add the language label
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-cloudflare"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - sonarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}.{{ required "A value for domain is required" .Values.domain }}
      secretName: sonarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}-tls-secret
  rules:
    - host: sonarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}.{{ required "A value for domain is required" .Values.domain }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: sonarr{{- if ne $lang "default" }}-{{ $lang }}{{- end }}-service
                port:
                  number: {{ include "utils.portByName" (dict "ports" .Values.sonarr.ports "portName" "http") }}
{{- end -}}
