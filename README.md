# attnprofiler

A proof of concept for profiling user attention.

It has a macos client written in SwiftUI that captures the foreground state and stores it using [OpenTelemetry](https://opentelemetry.io/). There are many backend implementations for exploring and analysing otel data, but I used [Jaeger](https://www.jaegertracing.io/), which has a slim local solution for developers.

## Repro

1. Clone this repository.
2. Load the attenprofiler project using xcode.
3. Use docker to run the trace collector: [Jaeger All in one](https://www.jaegertracing.io/docs/1.46/getting-started/)
4. Build and start the app in xcode.
5. In attnprofiler, press the start button. This starts the "workstream".
6. Do some normal stuff, switching between apps. attnprofiler should update with the foreground app.
7. In attnprofiler, press the stop button. This closes the "workstream".
8. (Optional) feel free to repeat steps 5-7 to add more data.
9. You can then navigate to http://localhost:16686 to access the Jaeger UI.
10. In Jaeger, switch to the Search tab and look for "attnprofiler" in the Services drop down.
11. Traces may take a couple of minutes to process and show up in the UI.

## More documentation

- Great overview of Open Telemetry - https://github.com/magsther/awesome-opentelemetry#open-source
- Swift specific implementation - https://opentelemetry.io/docs/instrumentation/swift/
- Comprehensive self-contained demo of OT - https://github.com/open-telemetry/opentelemetry-demo
