import SwiftUI
import RealityKit

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed

    private(set) var entities: [(content: RealityViewContent, entity: Entity)] = []
    func addNewEntity(in content: RealityViewContent) -> Entity {
        let e = ModelEntity(mesh: .generateSphere(radius: 0.03), materials: [SimpleMaterial(color: .white, isMetallic: false)])
        content.add(e)
        entities.append((content, e))
        return e
    }

    private(set) var needsUpdateCoordinateSpaces = false
    // var forcesImmersiveSpaceOnUpdate = true

    func setNeedsUpdateCoordinateSpaces() async {
        needsUpdateCoordinateSpaces = true
        try! await Task.sleep(for: .milliseconds(100))
        updateCoordinateSpacesIfNeeded()
    }
    func updateCoordinateSpacesIfNeeded() {
        guard needsUpdateCoordinateSpaces else { return }
        struct E: Error {}
        do {
            for (xc, xe) in entities {
                let directionHeight: Float = 0.2
                let directionRadius: Float = 0.005
                // reuse or create or delete
                let needs = entities.count - 1
                let removes = max(0, xe.children.count - needs)
                xe.children.reversed().prefix(removes).forEach { $0.removeFromParent() }
                if needs > xe.children.count {
                    (xe.children.count..<needs).forEach { _ in
                        let d = ModelEntity(mesh: .generateCylinder(height: directionHeight, radius: directionRadius), materials: [SimpleMaterial(color: .cyan, isMetallic: true)])
                        xe.addChild(d)
                    }
                }

                try entities.filter {$0.entity.id != xe.id}.enumerated().forEach { (i, y) in
                    let (yc, ye) = y
                    let d = xe.children[i]

                    let xToImmersive = xc.transform(from: xe, to: .immersiveSpace)
                    let xToGlobal = xc.transform(from: xe, to: .global)

                    guard xToImmersive != xToGlobal else {
                        // detect that immersive space is not usable
                        throw E()
                    }

                    let yToImmersive = yc.transform(from: ye, to: .immersiveSpace)
                    guard let immersiveToX = xToImmersive.inverse else { return }
                    // let immersiveZeroInX = Point3D.zero.applying(immersiveToX)

                    let yInImmersive = Point3D(ye.position).applying(yToImmersive)
                    let yInX = yInImmersive.applying(immersiveToX)

                    d.transform = Transform(AffineTransform3D.identity
                        .rotated(by: Rotation3D(target: yInX))
                        .rotated(by: Rotation3D(angle: .degrees(90), axis: .x))
                        .translated(by: Vector3D(x: 0, y: directionHeight / 2, z: 0))
                    )
                }
            }
            // all coordinates are resolved
            needsUpdateCoordinateSpaces = false
        } catch {
            NSLog("%@", "xToImmersive == xToGlobal")
            needsUpdateCoordinateSpaces = true
        }
    }
}
