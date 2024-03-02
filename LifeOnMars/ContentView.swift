//
//  ContentView.swift
//  LifeOnMars
//
//  Created by Antonio Sanchez-Rivas on 10/2/2024.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var ThisEmulatorCore = EmulatorCore()
    
    let CoreUpdateFreq : Double = 0.1
    
    let timer = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Spacer()
        HStack {
            Spacer()
            VStack  {
                Spacer()
                Grid(horizontalSpacing: 1.0, verticalSpacing: 1.0) {
                    ForEach(0..<ThisEmulatorCore.CoreSizeInRows) { MyIndexRow in
                        GridRow {
                            ForEach(0..<ThisEmulatorCore.CoreSizeInCols) { MyIndexCol in
                                Rectangle().fill(ThisEmulatorCore.Core[(MyIndexRow*ThisEmulatorCore.CoreSizeInCols)+MyIndexCol].InstructionColour)
                            }
                        }
                        .frame(width: 15.0, height: 15.0)
                    }
                }
                Spacer()
                List {
                    ForEach(0..<ThisEmulatorCore.CoreSize) { MyIndex in Text(ThisEmulatorCore.FormatCoreOutput(MyIndex)).monospaced().foregroundColor(ThisEmulatorCore.Core[MyIndex].InstructionColour)
                    }
                }
            }
            Spacer()
            VStack(alignment: .leading) {
                List  {
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
                        ThisEmulatorCore.SetCoreCycles(1000)
                        ThisEmulatorCore.CoreRunMode(true)
                        //ThisEmulatorCore.CoreExecute()
                    }
                    Button("End Battle") {
                        ThisEmulatorCore.CoreRunMode(false)
                    }
                    Button("Load Warriors") {
                        ThisEmulatorCore.SetCoreCycles(1000)
                        ThisEmulatorCore.LoadCore()
                    }
                    Button("Reset Core") {
                        ThisEmulatorCore.ResetCore()
                    }
                    .onReceive(timer) { timerthingy in
                        if ThisEmulatorCore.Warriors.count > 0 && ThisEmulatorCore.CoreRunning {
                            ThisEmulatorCore.CoreStepExecute()}
                    }
            }
            Spacer()
        }
        Spacer()
    }
}

#Preview {
    ContentView()
}
