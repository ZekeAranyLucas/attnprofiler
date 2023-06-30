//
//  ContentView.swift
//  attnprofiler
//
//  Created by Zeke on 29.06.23.
//

import SwiftUI

struct ContentView: View {
    @State private var streamName = "stream"
    @State private var isWorking = false
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            ForegroundAppView()
        }
        .padding()
        .toggleStyle(.switch)

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


