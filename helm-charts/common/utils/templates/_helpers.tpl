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