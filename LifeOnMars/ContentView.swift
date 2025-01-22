//
//  ContentView.swift
//  LifeOnMars
//
//  Created by Antonio Sanchez-Rivas on 10/2/2024.

//  Version 0.23 22/1/2025

import SwiftUI

struct CoreDisplayView: View {
    
    @EnvironmentObject var ThisEmulatorCore : EmulatorCore
    
    var body: some View {
        
        VStack {  TimelineView(.animation)
            { context in
                Rectangle()
                    .fill(.red)
                    .frame(width: 100.0, height: 80.0)
                    .colorEffect(ShaderLibrary.DrawCore(.floatArray(ThisEmulatorCore.CoreBuffer)))
                    .scaleEffect(x: 7.0, y:7.0)
                    .onChange(of: context.date)
                {
                    ThisEmulatorCore.CoreStepExecute()
                } // End onChnage
            } // End context
        }
    } //End body
}  // End CoreDisplayView

#Preview {
    CoreDisplayView()
}  // End Preview

struct WarriorDisplayView: View {
    
    @EnvironmentObject var ThisEmulatorCore : EmulatorCore
    
    var body: some View {
        
        VStack{
            if ThisEmulatorCore.Warriors.count > 0 {
            List {
                ForEach(0..<ThisEmulatorCore.Warriors.count, id: \.self) { item in
                    Toggle(isOn: $ThisEmulatorCore.CoreWarriorQueue[item].WarriorProgramStatus)  {Text(ThisEmulatorCore.Warriors[item].WarriorProgramTitle+" @ Address "+String(ThisEmulatorCore.Warriors[item].WarriorStartCoreAddress)).foregroundColor(ThisEmulatorCore.Warriors[item].WarriorColour)}.toggleStyle(.switch).disabled(true)
                } // End ForEach
            }  // End List
        } // End if
            else {
                List {
                    Text("No warriors loaded")
                } // End List
            } // End else
        }
    } // End body
}  // End WarriorDisplayView

#Preview {
    WarriorDisplayView()
}  // End Preview

struct WarriorControlView: View {
    
    @EnvironmentObject var ThisEmulatorCore : EmulatorCore
    
    var body: some View {
        
        HStack{
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
            Button("Load Warriors")
            {
                ThisEmulatorCore.SetCoreCycles(1000)
                ThisEmulatorCore.LoadCore()
            }
            .buttonStyle(.borderedProminent)
            Button("Reset Core")
            {
                ThisEmulatorCore.ResetCore()
            }
            .buttonStyle(.borderedProminent) }
    } // End body
}  // End WarriorControlView

#Preview {
    WarriorControlView()
}  // End Preview

struct CoreMemoryView: View {
    
    @EnvironmentObject var ThisEmulatorCore : EmulatorCore
    
    var body: some View {
        
        VStack {
            List {
            ForEach(0..<ThisEmulatorCore.CoreSize, id: \.self) { MyIndex in Text(ThisEmulatorCore.FormatCoreOutput(MyIndex)).monospaced().foregroundColor(ThisEmulatorCore.Core[MyIndex].InstructionColour)
            } // End ForEach
        } // End List
        }
    } // End body
}  // CoreMemoryView

#Preview {
    CoreMemoryView()
}  // End Preview


struct ContentView: View {
    
    @StateObject var ThisEmulatorCore = EmulatorCore()
    
    var body: some View {
        CoreDisplayView().environmentObject(ThisEmulatorCore).frame(width:1000,height:560)
        CoreMemoryView().environmentObject(ThisEmulatorCore).frame(width:1000,height:120)
        WarriorDisplayView().environmentObject(ThisEmulatorCore).frame(width:1000,height:80)
        WarriorControlView().environmentObject(ThisEmulatorCore).frame(width:1000,height:50)
    } // End body
}  // End ContentView

#Preview {
    ContentView()
}  // End Preview
