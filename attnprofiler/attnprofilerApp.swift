//
//  attnprofilerApp.swift
//  attnprofiler
//
//  Created by Zeke on 29.06.23.
//

import SwiftUI
import OpenTelemetryApi
import OpenTelemetrySdk
import StdoutExporter


@main
struct attnprofilerApp: App {
    @StateObject private var telemetryTracer = TelemetryTracer()


    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(telemetryTracer)
        }
    }
}

class TelemetryTracer: ObservableObject {
    let instrumentationScopeName = "attnprofiler"
    let instrumentationScopeVersion = "semver:0.1.0"
    let tracer : Tracer
    
    init() {

        // TODO: let otlpTraceExporter = OtlpTraceExporter(channel: client)
        let stdoutExporter = StdoutExporter()
        let spanExporter = MultiSpanExporter(spanExporters: [stdoutExporter])
        
        let spanProcessor = SimpleSpanProcessor(spanExporter: spanExporter)
        OpenTelemetry.registerTracerProvider(tracerProvider:
            TracerProviderBuilder()
                .add(spanProcessor: spanProcessor)
                .build()
        )

        self.tracer = OpenTelemetry.instance.tracerProvider.get(
            instrumentationName: instrumentationScopeName,
            instrumentationVersion: instrumentationScopeVersion)
    }

    func startSpan(_ name: String, parent: Span? = nil) -> Span {
        print("[TelemetryTracer.startSpan] \(name)")
        let builder = tracer.spanBuilder(spanName: name)
            .setSpanKind(spanKind: .client)
        if let parent = parent {
            builder.setParent(parent)
        }
        return builder.startSpan()
    }
}
