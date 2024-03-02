//
//  LifeOnMarsApp.swift
//  LifeOnMars
//
//  Created by Antonio Sanchez-Rivas on 10/2/2024.
//

import SwiftUI

@main
struct LifeOnMarsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands
        {
            CommandGroup(replacing: .help) {
                Link("Core Wars Reference Guide", destination: URL(string: "https://corewar-docs.readthedocs.io/en/latest/")!)
                Divider()
            }
            CommandGroup(after: .help) {
                Link("Hello to Jason Isaacs", destination: URL(string: "https://www.kermodeandmayo.com")!)
            }
        }
    }
}
