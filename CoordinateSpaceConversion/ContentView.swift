import SwiftUI
import RealityKit

struct ContentView: View {
    @Environment(AppModel.self) private var appModel
//    @Environment(\.physicalMetrics) private var physicalMetrics // for frequent update

    var body: some View {
        RealityView { content in
            _ = appModel.addNewEntity(in: content)
        } update: { content in
            // print(physicalMetrics)
            Task { await appModel.setNeedsUpdateCoordinateSpaces() }
        }
    }
}
