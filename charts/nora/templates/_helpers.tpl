{{/*
Expand the name of the chart.
*/}}
{{- define "nora.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "nora.fullname" -}}
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
{{- define "nora.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "nora.labels" -}}
helm.sh/chart: {{ include "nora.chart" . }}
{{ include "nora.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "nora.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nora.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use.
*/}}
{{- define "nora.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "nora.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Image reference. Tag defaults to Chart.appVersion; set image.tag to override.
*/}}
{{- define "nora.image" -}}
{{- $tag := .Chart.AppVersion }}
{{- if .Values.image.tag }}
{{- $tag = .Values.image.tag }}
{{- end }}
{{- printf "%s:%s" .Values.image.repository $tag }}
{{- end }}

{{/*
Resolved htpasswd file path for config.toml (explicit htpasswd_file or Secret mount).
*/}}
{{- define "nora.auth.htpasswdFile" -}}
{{- if .Values.config.auth.htpasswd_file }}
{{- .Values.config.auth.htpasswd_file }}
{{- else if .Values.config.auth.htpasswd.existingSecret }}
{{- printf "%s/%s" .Values.config.auth.htpasswd.mountPath (.Values.config.auth.htpasswd.secretKey | default "users.htpasswd") }}
{{- end }}
{{- end }}
