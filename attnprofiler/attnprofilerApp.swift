//
//  attnprofilerApp.swift
//  attnprofiler
//
//  Created by Zeke on 29.06.23.
//

import SwiftUI
import GRPC
import NIO
import OpenTelemetryApi
import OpenTelemetryProtocolExporterCommon
import OpenTelemetryProtocolExporterGrpc
import OpenTelemetrySdk
import StdoutExporter
import ResourceExtension


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

        //  traces sent to collector for storage and exploration
        let otlpConfiguration = OtlpConfiguration(timeout: OtlpConfiguration.DefaultTimeoutInterval)
        let configuration = ClientConnection.Configuration.default(
            target: .hostAndPort("localhost", 4317),
            eventLoopGroup: MultiThreadedEventLoopGroup(numberOfThreads: 1)
        )
        let client = ClientConnection(configuration: configuration)

        let traceExporter = OtlpTraceExporter(channel: client, config: otlpConfiguration)
        
        //  traces sent to console for debugging
        let stdoutExporter = StdoutExporter()

        let spanExporter = MultiSpanExporter(spanExporters: [traceExporter, stdoutExporter])

        
        let spanProcessor = SimpleSpanProcessor(spanExporter: spanExporter)
        OpenTelemetry.registerTracerProvider(tracerProvider:
            TracerProviderBuilder()
                .add(spanProcessor: spanProcessor)
                .with(resource: DefaultResources().get())
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
