import SwiftUI
import OpenTelemetryApi
import Cocoa

struct ForegroundAppView: View {
    @State private var isDetectionActive = false
    @State private var foregroundApps: [(id: Int, app: String, timestamp: Date)] = []
    @State private var appObserver: NSObjectProtocol? = nil
    @State private var nextID: Int = 0
    @State private var foregroundSpan: Span?

    @EnvironmentObject private var telemetryTracer: TelemetryTracer


    var body: some View {
        VStack {
            List {
                ForEach(foregroundApps, id: \.id) { entry in
                    HStack {
                        Text(entry.app)
                            .font(.headline)
                        Spacer()
                        Text("ID: \(entry.id)")
                            .font(.subheadline)
                        Text("Timestamp: \(formatTimestamp(entry.timestamp))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            Button(action: {
                if isDetectionActive {
                    stopDetection()
                } else {
                    startDetection()
                }
            }) {
                Text(isDetectionActive ? "Stop Detection" : "Start Detection")
                    .padding()
                    .cornerRadius(10)
            }
            .padding()

        }
    }

    private func formatTimestamp(_ timestamp: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return dateFormatter.string(from: timestamp)
    }
    
    fileprivate func onForegroundApp(_ appName: String) {
        foregroundSpan?.end()
        // TODO: should span vary name based on app (or static with an appName attribute)
        foregroundSpan = telemetryTracer.startSpan("foreground-app")
        foregroundSpan!.setAttribute(key: "appName", value: appName)

        // in memory UX
        nextID += 1
        let entry = (id: nextID, app: appName, timestamp: Date())
        foregroundApps.append(entry)
        
        // Keep only the last 10 apps in the list
        if foregroundApps.count > 10 {
            foregroundApps.removeFirst()
        }
    }
    
    private func startDetection() {
        isDetectionActive = true
        foregroundApps.removeAll()
        
        // Start detecting foreground apps and update the list
        appObserver = NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: nil) { notification in
            if let activatedApp = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
               let appName = activatedApp.localizedName {
                DispatchQueue.main.async {
                    onForegroundApp(appName)
                }
            }
        }

    }

    private func stopDetection() {
        isDetectionActive = false
        NSWorkspace.shared.notificationCenter.removeObserver(appObserver!, name: NSWorkspace.didActivateApplicationNotification, object: nil)
        appObserver = nil
    }
}
