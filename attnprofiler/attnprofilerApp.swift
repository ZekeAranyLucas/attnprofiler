//
//  attnprofilerApp.swift
//  attnprofiler
//
//  Created by Zeke on 29.06.23.
//

import SwiftUI

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

    init() {
        // Initialize your telemetry tracing object here
        // ...
    }

    func trace(_ message: String) {
        print("[TelemetryTracer] \(message)")
    }
}
