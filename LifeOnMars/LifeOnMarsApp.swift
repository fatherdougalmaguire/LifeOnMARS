//
//  LifeOnMarsApp.swift
//  LifeOnMars
//
//  Created by Antonio Sanchez-Rivas on 10/2/2024.
//  Version 0.1 3/3/2024
//  Version 0.2 10/3/2024

import SwiftUI

@main
struct LifeOnMarsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands
        {
            AboutPanelCommand(
                            title: "About LifeOnMARS",
                            applicationName: "LifeOnMARS",
                            credits: "\nLifeOnMARS is a Core Wars environment written in Swift/SwiftUI.\n\n It is a fully compliant ISCW 94 MARS virtual machine as well as IDE, Debugger, Hill functionality and Warrior evolution capability.\n\n And hello to Jason Isaacs\n"
                        )
            CommandMenu("Debugger") {
                Button("Nothing to see here folks") {
                }.keyboardShortcut("D")
            }
            CommandMenu("IDE") {
                Button("Nothing to see here folks") {
                }.keyboardShortcut("I")
            }
            CommandMenu("Warrior Evolution") {
                Button("Nothing to see here folks") {
                }.keyboardShortcut("W")
            }
            CommandMenu("Hill") {
                Button("Nothing to see here folks") {
                }.keyboardShortcut("H")
            }
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
