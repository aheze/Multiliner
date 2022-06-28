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
            VStack(alignment: .leading) {
                Link(destination: URL(string: "https://github.com/aheze/Multiliner")!) {
                    Text("View on GitHub")
                }

                Text("Multiliner")
                    .font(.largeTitle)
                    .bold()

                Text("An Xcode source extension to expand lengthy lines.")
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                Divider()

                Group {
                    Text("Installation")
                        .font(.title2)
                        .bold()

                    Text("Now that you have the app installed, just head over to System Preferences and check `MultilinerExtension`.")
                        .font(.title3)

                    Image("Preferences")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }

                Group {
                    Group {
                        Text("Usage")
                            .font(.title2)
                            .bold()

                        Text("1. Select some code in Xcode. Make sure to include the opening and closing braces.")
                            .font(.title3)

                        Image("UsageCode")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }

                    Group {
                        Text("2. Then, go to Editor → Multiliner → Format Selected Code. Your code will get reformatted!")
                            .font(.title3)

                        HStack {
                            Image("UsageMenu")
                                .resizable()
                                .aspectRatio(contentMode: .fit)

                            Image("UsageResult")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                    Group {
                        Text("3. To make this extension easier to reach, consider adding an App Shortcut in system preferences.")
                            .font(.title3)

                        Image("UsageShortcut")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
            }
            .padding(.horizontal, 64)
            .padding(.vertical, 32)
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
