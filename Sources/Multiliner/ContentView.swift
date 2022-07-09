//
//  ContentView.swift
//  Multiliner
//
//  Created by A. Zheng (github.com/aheze) on 6/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image("Banner")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Multiliner")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("An Xcode source extension to expand lengthy lines.")
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("Installation")
                            .font(.title2)
                            .bold()
                    
                        Text("Now that you have the app installed, just head over to System Preferences and check `Multiliner`.")
                            .font(.title3)
                    
                        Screenshot(image: "Preferences")
                    
                        Text("System Preferences → Extensions → Xcode Source Editor")
                            .font(.caption)
                            .textCase(.uppercase)
                    }
                
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("Usage")
                                .font(.title2)
                                .bold()
                        
                            Text("1. Select some code in Xcode. Make sure to include the opening and closing braces.")
                                .font(.title3)
                        
                            Image("UsageCode")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    
                        VStack(alignment: .leading) {
                            Text("2. Then, go to Editor → Multiliner → Format Selected Code. Your code will get reformatted!")
                                .font(.title3)
                        
                            HStack(alignment: .top) {
                                Image("UsageMenu")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(8)
                                    .shadow(
                                        color: .black.opacity(0.25),
                                        radius: 16,
                                        x: 0,
                                        y: 2
                                    )
                                    
                                Image("UsageResult")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(8)
                                    .shadow(
                                        color: .black.opacity(0.25),
                                        radius: 16,
                                        x: 0,
                                        y: 2
                                    )
                            }
                        }
                    
                        VStack(alignment: .leading) {
                            Text("3. To make this extension easier to reach, consider adding a shortcut in Xcode's Key Bindings.")
                                .font(.title3)
                        
                            Screenshot(image: "UsageShortcut")
                        
                            Text("Xcode → Preferences → Key Bindings")
                                .font(.caption)
                                .textCase(.uppercase)
                        }
                    }
                }
                
                Divider()
                
                Text("That's it! If you have any questions or suggestions, feel free to ping me on Twitter ([@aheze0](https://twitter.com/aheze0)), join the [Discord](https://discord.gg/Pmq8fYcus2), or [open an issue](https://github.com/aheze/Multiliner/issues).")
            }
            .frame(maxWidth: 800)
            .padding(.horizontal, 64)
            .padding(.vertical, 32)
            .frame(maxWidth: .infinity)
        }
        .frame(
            minWidth: 400,
            idealWidth: 500,
            maxWidth: .infinity,
            minHeight: 300,
            idealHeight: 700,
            maxHeight: .infinity,
            alignment: .leading
        )
        .navigationTitle("Multiliner")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    if let url = URL(string: "https://github.com/aheze/Multiliner") {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Text("View on GitHub")
                }

                Button {
                    if let url = URL(string: "https://github.com/aheze/Multiliner/issues") {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Text("Help")
                }
            }
        }
    }
}

struct Screenshot: View {
    var image: String
    var body: some View {
        Image(image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: 600)
            .padding(.horizontal, -42)
            .padding(.top, -20)
            .padding(.bottom, -40)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
