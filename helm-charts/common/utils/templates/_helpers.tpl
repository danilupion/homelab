{{/*
Determine the value for any property for a generic service
Usage:
  include "service.value" (dict "context" . "prop" "uid")
*/}}
{{- define "service.value" -}}
{{- $propertyName := .prop | required "You must specify a prop name!" -}}
{{- $servicePropertyKey := printf "%s.%s" .context.Chart.Name $propertyName -}}
{{- $defaultPropertyKey := printf "%s" $propertyName -}}
{{- $value := coalesce (index .context.Values .context.Chart.Name $propertyName) (index .context.Values $propertyName) -}}
{{- required (printf "A valid .Values.%s or .Values.%s is required!" $defaultPropertyKey $servicePropertyKey) $value -}}
{{- end -}}

{{/*
Determine a service subdomain
Usage:
  include "service.subdomain" .
*/}}
{{- define "service.subdomain" -}}
{{- coalesce (index .Values .Chart.Name "subdomain") .Chart.Name -}}
{{- end -}}

{{/*
Determine a service volumes
Usage:
  include "service.volumes" .
*/}}
{{- define "service.volumes" -}}
{{- index .Values .Chart.Name "volumes" | toYaml | trim -}}
{{- end -}}

{{/*
Determine a service volumeMounts
Usage:
  include "service.volumeMounts" .
*/}}
{{- define "service.volumeMounts" -}}
{{- index .Values .Chart.Name "volumeMounts" | toYaml | trim -}}
{{- end -}}

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
  include "media.volumeMounts" (dict "mediaPaths" .Values.object.mediaPaths "mediaTypes" .Values.object.mediaTypes)
*/}}
{{- define "media.volumeMounts" -}}
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
  include "media.volumes" (dict "mediaPaths" .Values.object.mediaPaths "mediaTypes" .Values.object.mediaTypes)
*/}}
{{- define "media.volumes" -}}
{{- $mediaPaths := .mediaPaths -}}
{{- $mediaTypes := .mediaTypes -}}
{{- $suffix := .suffix | default "" -}}
{{- range $mediaTypes -}}
{{- $mediaType := . -}}
{{- range (index $mediaPaths $mediaType) -}}
- name: {{ .name }}
  hostPath:
    path: {{ if and .localize (ne $suffix "") }}{{ .path }}-{{ $suffix }}{{ else }}{{ .path }}{{ end }}
{{ end }}
{{ end }}
{{- end -}}

{{/*
Generate volumeMounts for a specified service, including language-specific mounts
Usage:
  include "media.volumeMounts" (dict "mediaPaths" .Values.paths.mediaPaths "mediaTypes" .Values.jellyfin.mediaTypes "extraMediaLanguages" .Values.jellyfin.extraMediaLanguages)
*/}}
{{- define "media.volumeMounts-localized" -}}
{{- $mediaPaths := .mediaPaths -}}
{{- $mediaTypes := .mediaTypes -}}
{{- $extraMediaLanguages := .extraMediaLanguages | default (list) -}}
{{- range $mediaType := $mediaTypes -}}
{{- range (index $mediaPaths $mediaType) -}}
{{- $localize := .localize -}}
{{- $name := .name -}}
- name: {{ .name }}
  mountPath: /{{ .name }}
{{ "\n" }}
{{- range $language := $extraMediaLanguages -}}
{{- if $localize -}}
- name: {{ $name }}-{{ $language }}
  mountPath: /{{ $name }}-{{ $language }}
{{ "\n" }}
{{- end -}}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}


{{/*
Generate volumes for a specified service, including language-specific volumes
Usage:
  include "media.volumes" (dict "mediaPaths" .Values.object.mediaPaths "mediaTypes" .Values.object.mediaTypes "extraMediaLanguages" .Values.jellyfin.extraMediaLanguages)
*/}}
{{- define "media.volumes-localized" -}}
{{- $mediaPaths := .mediaPaths -}}
{{- $mediaTypes := .mediaTypes -}}
{{- $extraMediaLanguages := .extraMediaLanguages | default (list) -}}
{{- range $mediaType := $mediaTypes -}}
{{- range (index $mediaPaths $mediaType) -}}
{{- $localize := .localize -}}
{{- $name := .name -}}
{{- $path := .path -}}
- name: {{ .name }}
  hostPath:
    path: {{ $path }}
{{ "\n" }}
{{- range $language := $extraMediaLanguages -}}
{{- if $localize -}}
- name: {{ $name }}-{{ $language }}
  hostPath:
    path: {{ $path }}-{{ $language }}
{{ "\n" }}
{{- end -}}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

