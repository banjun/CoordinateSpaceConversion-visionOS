//
//  CoordinateSpaceConversionApp.swift
//  CoordinateSpaceConversion
//
//  Created by BAN Jun on 2024/10/01.
//

import SwiftUI

@main
struct CoordinateSpaceConversionApp: App {
    @State private var appModel = AppModel()
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some Scene {
        WindowGroup(id: "Main") {
            HStack {
                Button("Add Volume") { openWindow(id: "Volume") }.padding()
                Button("Add Plain") { openWindow(id: "Plain") }.padding()
            }

            ToggleImmersiveSpaceButton()
                .environment(appModel)
                .padding()

            Button("Update using temporary Immersive Space") {
                Task {
                    appModel.immersiveSpaceState = .inTransition
                    switch await openImmersiveSpace(id: appModel.immersiveSpaceID) {
                    case .opened:
                        await appModel.setNeedsUpdateCoordinateSpaces()
                        await dismissImmersiveSpace()
                    case .error, .userCancelled: break
                    @unknown default: break
                    }
                }
            }
            .fixedSize()
            .padding()
        }
        .windowResizability(.contentSize)
        .defaultSize(.init(width: 400, height: 400))

        WindowGroup(id: "Volume") {
            ContentView()
                .environment(appModel)
        }
        .windowStyle(.volumetric)

        WindowGroup(id: "Plain") {
            ContentView()
                .environment(appModel)
        }
        .windowStyle(.automatic)

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
