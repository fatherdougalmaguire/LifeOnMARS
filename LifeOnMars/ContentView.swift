//
//  ContentView.swift
//  LifeOnMars
//
//  Created by Antonio Sanchez-Rivas on 10/2/2024.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var ThisEmulatorCore = EmulatorCore()
    
    var body: some View {
        Spacer()
        HStack {
            Spacer()
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(0..<ThisEmulatorCore.CoreSize) { MyIndex in Text(ThisEmulatorCore.FormatCoreOutput(MyIndex)).monospaced().foregroundColor(ThisEmulatorCore.Core[MyIndex].InstructionColour)
                    }
                }
            }
            Spacer()
            VStack(alignment: .leading) {
                ScrollView  {
                    VStack(alignment: .leading) {
                        if ThisEmulatorCore.Warriors.count > 0 {
                            ForEach(0..<ThisEmulatorCore.Warriors.count) { MyIndex in
                                Text(ThisEmulatorCore.Warriors[MyIndex].WarriorProgramTitle+" @ Address "+String(ThisEmulatorCore.Warriors[MyIndex].WarriorStartCoreAddress))
                                    .foregroundColor(ThisEmulatorCore.Warriors[MyIndex].WarriorColour)
                            }
                        }
                    }
                }
                Button("Start Battle") {
                    ThisEmulatorCore.SetCoreCycles(10)
                    ThisEmulatorCore.CoreRunMode(true)
                    ThisEmulatorCore.CoreExecute()
                }
                Button("End Battle") {
                    ThisEmulatorCore.CoreRunMode(false)
                }
                Button("Load Warriors") {
                    ThisEmulatorCore.SetCoreCycles(10)
                    ThisEmulatorCore.LoadCore()
                }
                Button("Reset Core") {
                    ThisEmulatorCore.ResetCore()
                }
                Button("Step Through Core") {
                    ThisEmulatorCore.CoreStepExecute()
                }
            }
            Spacer()
        }
        //       VStack {
        //            ForEach(1..<25) { Vindex in
        //                HStack {
        //                    ForEach(1..<25) { Hindex in
        //                        Rectangle()
        //                            .fill(.red)
        //                            .aspectRatio(1.0, contentMode: .fit)
        //                    }
        //                }
        //            }
        //        }
        Spacer()
    }
}

#Preview {
    ContentView()
}
