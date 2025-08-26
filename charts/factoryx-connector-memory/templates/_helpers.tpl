{{/*
Expand the name of the chart.
*/}}
{{- define "fxdc.name" -}}
{{- default .Chart.Name .Values.nameOverride | replace "+" "_"  | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fxdc.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "fxdc.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Control Common labels
*/}}
{{- define "fxdc.labels" -}}
helm.sh/chart: {{ include "fxdc.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Control Common labels
*/}}
{{- define "fxdc.runtime.labels" -}}
helm.sh/chart: {{ include "fxdc.chart" . }}
{{ include "fxdc.runtime.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: edc-runtime
app.kubernetes.io/part-of: edc
{{- end }}

{{/*
Control Selector labels
*/}}
{{- define "fxdc.runtime.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fxdc.name" . }}-runtime
app.kubernetes.io/instance: {{ .Release.Name }}-runtime
{{- end }}

{{/*
Data Selector labels
*/}}
{{- define "fxdc.dataplane.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fxdc.name" . }}-dataplane
app.kubernetes.io/instance: {{ .Release.Name }}-dataplane
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "fxdc.runtime.serviceaccount.name" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "fxdc.fullname" . ) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Control DSP URL
*/}}
{{- define "fxdc.runtime.url.protocol" -}}
{{- if .Values.runtime.url.protocol }}{{/* if dsp api url has been specified explicitly */}}
{{- .Values.runtime.url.protocol }}
{{- else }}{{/* else when dsp api url has not been specified explicitly */}}
{{- with (index .Values.runtime.ingresses 0) }}
{{- if .enabled }}{{/* if ingress enabled */}}
{{- if .tls.enabled }}{{/* if TLS enabled */}}
{{- printf "https://%s" .hostname -}}
{{- else }}{{/* else when TLS not enabled */}}
{{- printf "http://%s" .hostname -}}
{{- end }}{{/* end if tls */}}
{{- else }}{{/* else when ingress not enabled */}}
{{- printf "http://%s-runtime:%v" ( include "fxdc.fullname" $ ) $.Values.runtime.endpoints.protocol.port -}}
{{- end }}{{/* end if ingress */}}
{{- end }}{{/* end with ingress */}}
{{- end }}{{/* end if .Values.runtime.url.protocol */}}
{{- end }}

{{/*
Validation URL
*/}}
{{- define "fxdc.runtime.url.validation" -}}
{{- printf "%s/token" ( include "fxdc.runtime.url.control" $ ) -}}
{{- end }}

{{/*
Control URL
*/}}
{{- define "fxdc.runtime.url.control" -}}
{{- printf "http://%s-runtime:%v%s" ( include "fxdc.fullname" $ ) $.Values.runtime.endpoints.control.port $.Values.runtime.endpoints.control.path -}}
{{- end }}

{{/*
Data Public URL
*/}}
{{- define "fxdc.dataplane.url.public" -}}
{{- if .Values.runtime.url.public }}{{/* if public api url has been specified explicitly */}}
{{- .Values.runtime.url.public }}
{{- else }}{{/* else when public api url has not been specified explicitly */}}
{{- with (index  .Values.runtime.ingresses 0) }}
{{- if .enabled }}{{/* if ingress enabled */}}
{{- if .tls.enabled }}{{/* if TLS enabled */}}
{{- printf "https://%s%s" .hostname $.Values.runtime.endpoints.public.path -}}
{{- else }}{{/* else when TLS not enabled */}}
{{- printf "http://%s%s" .hostname $.Values.runtime.endpoints.public.path -}}
{{- end }}{{/* end if tls */}}
{{- else }}{{/* else when ingress not enabled */}}
{{- printf "http://%s-dataplane:%v%s" (include "fxdc.fullname" $ ) $.Values.runtime.endpoints.public.port $.Values.runtime.endpoints.public.path -}}
{{- end }}{{/* end if ingress */}}
{{- end }}{{/* end with ingress */}}
{{- end }}{{/* end if .Values.dataplane.url.public */}}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "fxdc.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "fxdc.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
