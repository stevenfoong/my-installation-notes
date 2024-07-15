### Install Cpllector service ###
```
 $params = @{
>>   Name = "OpenTelemetry Collector Contrib"
>>   BinaryPathName = "C:\Program Files\otelcol-contrib_0.103.0_windows_amd64\otelcol-contrib.exe --config `"C:\Program Files\otelcol-contrib_0.103.0_windows_amd64\otel-collector-config.yaml`""
>>   DisplayName = "OTel Collector Contrib"
>>   StartupType = "Automatic"
>>   Description = "OpenTelemetry Collector Contrib"

New-Service @params
```

### Configuration file ###

```
receivers:
  filelog:
    include: [ D:\Logs\*.log ]
    start_at: end
    operators:
      - type: add
        field: attributes.server_name
        value: api01
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318
  hostmetrics:
    collection_interval: 30s
    scrapers:
      cpu: {}
      disk: {}
      load: {}
      filesystem: {}
      memory: {}
      network: {}
      paging: {}
      process:
        mute_process_name_error: true
        mute_process_exe_error: true
        mute_process_io_error: true
      processes: {}
  prometheus:
    config:
      global:
        scrape_interval: 30s
      scrape_configs:
        - job_name: otel-collector-binary
          static_configs:
            - targets: ['localhost:8888']
processors:
  batch:
    send_batch_size: 10000
    send_batch_max_size: 11000
    timeout: 10s
  # Ref: https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/processor/resourcedetectionprocessor/README.md
  resourcedetection:
    detectors: [env, system] # include ec2 for AWS, gcp for GCP and azure for Azure.
    # Using OTEL_RESOURCE_ATTRIBUTES envvar, env detector adds custom labels.
    timeout: 2s
    system:
      hostname_sources: [os] # alternatively, use [dns,os] for setting FQDN as host.name and os as fallback
extensions:
  health_check: {}
  zpages: {}
exporters:
  otlp:
    endpoint: http://172.16.6.208:4317
    tls:
      insecure: true
  otlp/log:
    endpoint: http://172.16.6.208:4317
    tls:
      insecure: true
  logging:
    # verbosity of the logging export: detailed, normal, basic
    verbosity: normal
service:
  telemetry:
    metrics:
      address: 0.0.0.0:8888
  extensions: [health_check, zpages]
  pipelines:
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlp]
    metrics/internal:
      receivers: [prometheus, hostmetrics]
      processors: [resourcedetection, batch]
      exporters: [otlp]
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlp]
    logs:
      receivers: [filelog]
      processors: [batch]
      exporters: [ otlp/log ]

```

Download client from here : https://github.com/open-telemetry/opentelemetry-collector-releases/releases  
Download the client config from here for host metric : https://raw.githubusercontent.com/SigNoz/benchmark/main/docker/standalone/config.yaml  
Download the host metric dashboard from here : https://github.com/SigNoz/dashboards/blob/main/hostmetrics/hostmetrics-with-variable.json  
  
Reference : https://observiq.com/blog/how-to-monitor-host-metrics-with-opentelemtry  
https://signoz.io/docs/tutorial/opentelemetry-binary-usage-in-virtual-machine/  
https://signoz.io/docs/userguide/collect_logs_from_file/  
