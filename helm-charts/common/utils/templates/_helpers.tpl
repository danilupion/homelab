{{/*
Determine the port number for a given port name from a passed list of ports. If the port is not found, an error is thrown.
Usage:
  include "utils.portByName" (dict "ports" .Values.object.ports "portName" "web")
*/}}
{{- define "utils.portByName" -}}
{{- $ports := .ports -}}
{{- $portName := .portName -}}
{{- $foundPort :=  0 -}}
{{- $portFound := false -}}
{{- range $ports -}}
  {{- if eq .name $portName -}}
    {{- $foundPort = .port -}}
    {{- $portFound = true -}}
    {{- break -}}  {{/* This ensures we exit the loop once we've found a match */}}
  {{- end -}}
{{- end -}}
{{- if not $portFound -}}
  {{- fail (print "Port named '" $portName "' not found.") -}}
{{- end -}}
{{- $foundPort -}}
{{- end -}}

{{/*
Generate volumeMounts for a specified service
Usage:
  include "utils.volumeMounts" (dict "mediaPaths" .Values.object.mediaPaths "mediaTypes" .Values.object.mediaTypes)
*/}}
{{- define "utils.volumeMounts" -}}
{{- $mediaPaths := .mediaPaths -}}
{{- $mediaTypes := .mediaTypes -}}
{{- range $mediaTypes -}}
{{- $mediaType := . -}}
{{- range (index $mediaPaths $mediaType) -}}
- name: {{ .name }}
  mountPath: {{ .mountPath | default (print "/" .name) }}
{{ end }}
{{ end }}
{{- end -}}

{{/*
Generate volumes for a specified service
Usage:
  include "utils.volumes" (dict "mediaPaths" .Values.object.mediaPaths "mediaTypes" .Values.object.mediaTypes)
*/}}
{{- define "utils.volumes" -}}
{{- $mediaPaths := .mediaPaths -}}
{{- $mediaTypes := .mediaTypes -}}
{{- range $mediaTypes -}}
{{- $mediaType := . -}}
{{- range (index $mediaPaths $mediaType) -}}
- name: {{ .name }}
  hostPath:
    path: {{ .path }}
{{ end }}
{{ end }}
{{- end -}}