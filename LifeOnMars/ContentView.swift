//
//  ContentView.swift
//  LifeOnMars
//
//  Created by Antonio Sanchez-Rivas on 10/2/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Spacer()
        HStack {
            Spacer()
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(0..<8000) { MyIndex in
                        Text(FormatCoreOutput(MyIndex)).monospaced()
                    }
                }
            }
            Spacer()
            HStack {
                Button("Start") {
                    Core[10].AfieldAddress = 666
                }
                Button("Stop") {
                    /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
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
