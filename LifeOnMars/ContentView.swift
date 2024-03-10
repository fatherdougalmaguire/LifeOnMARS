//
//  ContentView.swift
//  LifeOnMars
//
//  Created by Antonio Sanchez-Rivas on 10/2/2024.
//  Version 0.1 3/3/2024
//  Version 0.2 10/3/2024

import SwiftUI

struct ContentView: View {
    
    @StateObject var ThisEmulatorCore = EmulatorCore()
    
    let timer = Timer.publish(every: 0.01 , on: .main, in: .common).autoconnect()
    
    var body: some View {
        Spacer()
        HStack {
            Spacer()
            VStack  {
                Spacer()
                Grid(horizontalSpacing: 1.0, verticalSpacing: 1.0) {
                    ForEach(0..<ThisEmulatorCore.CoreSizeInRows, id: \.self) { MyIndexRow in
                        GridRow {
                            ForEach(0..<ThisEmulatorCore.CoreSizeInCols, id: \.self) { MyIndexCol in
                                Rectangle().fill(ThisEmulatorCore.Core[(MyIndexRow*ThisEmulatorCore.CoreSizeInCols)+MyIndexCol].InstructionColour)
                            } // End ForEach
                        } // End GridRow
                        .frame(width: 15.0, height: 15.0)
                    } // End ForEach
                } // End Grid
                Spacer()
                List {
                    ForEach(0..<ThisEmulatorCore.CoreSize, id: \.self) { MyIndex in Text(ThisEmulatorCore.FormatCoreOutput(MyIndex)).monospaced().foregroundColor(ThisEmulatorCore.Core[MyIndex].InstructionColour)
                    } // End ForEach
                } // End List
            } // End Vstack
            Spacer()
            VStack {
                VStack {
                    if ThisEmulatorCore.Warriors.count > 0 {
                    List {
                        ForEach(0..<ThisEmulatorCore.Warriors.count, id: \.self) { item in
                            Toggle(isOn: $ThisEmulatorCore.CoreWarriorQueue[item].WarriorProgramStatus)  {Text(ThisEmulatorCore.Warriors[item].WarriorProgramTitle+" @ Address "+String(ThisEmulatorCore.Warriors[item].WarriorStartCoreAddress)).foregroundColor(ThisEmulatorCore.Warriors[item].WarriorColour)}.toggleStyle(.switch).disabled(true)
                        } // For Each
                        }  // End List
                    }  // End If
                    else {
                        List {
                            Text("No warriors loaded")
                            Spacer()
                        }
                       
                    }
                } // End VStack
                VStack {
                    Button("Start Battle")
                    {
                        ThisEmulatorCore.SetCoreCycles(1000)
                        ThisEmulatorCore.CoreRunMode(true)
                    }
                    .buttonStyle(.borderedProminent)
                    Button("End Battle")
                    {
                        ThisEmulatorCore.CoreRunMode(false)
                    }
                    .buttonStyle(.borderedProminent)
                    Button("Load Warriors", action:
                            {
                        ThisEmulatorCore.SetCoreCycles(1000)
                        ThisEmulatorCore.LoadCore()
                    })
                    .buttonStyle(.borderedProminent)
                    Button("Reset Core")
                    {
                        ThisEmulatorCore.ResetCore()
                    }
                    .buttonStyle(.borderedProminent)
                    .onReceive(timer) { timerthingy in
                        if ThisEmulatorCore.Warriors.count > 0 && ThisEmulatorCore.CoreRunning {
                            ThisEmulatorCore.CoreStepExecute()}
                    }
                    Spacer()
                } //End Vstack
            }
        }  // End Hstack
        .background(Color.white)
        Spacer()
    } // End body
}  // End ContentView

#Preview {
    ContentView()
}  // End Preview
