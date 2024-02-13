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
            HStack {
                Button("Start") {
                  
                       ThisEmulatorCore.LoadCore()
                    ThisEmulatorCore.CoreRunMode(true)
                         ThisEmulatorCore.CoreExecute()
                
                }
                Button("Stop") {
                   ThisEmulatorCore.CoreRunMode(false)
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
