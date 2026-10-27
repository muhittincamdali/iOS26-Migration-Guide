import SwiftUI

/// What this window scene knows about itself, read the way the iOS 26 SDK expects.
struct SceneScreen: View {
    let model: LabModel

    var body: some View {
        let scene = model.scene
        List {
            Section {
                LabeledContent("Session role", value: scene.role)
                LabeledContent("Connected scenes", value: "\(scene.connectedScenes)")
                LabeledContent("Windows in this scene", value: "\(scene.windowCount)")
                LabeledContent("Activations", value: "\(model.activations)")
            } header: {
                Text("Scene")
            } footer: {
                Text("UIApplication.shared.windows mixed every scene's windows; windowScene.windows holds this scene's. sceneDidBecomeActive(_:) counts the activations.")
            }
            Section {
                LabeledContent("Orientation", value: scene.orientation)
                LabeledContent("Orientation locked", value: scene.isOrientationLocked ? "Yes" : "No")
                LabeledContent("Display scale", value: scene.displayScale.formatted(.number.precision(.fractionLength(0...1))))
            } header: {
                Text("Geometry")
            } footer: {
                Text("effectiveGeometry.interfaceOrientation replaces UIWindowScene.interfaceOrientation, and the trait collection's displayScale replaces UIScreen.main.scale. Rotate the device to see the values change.")
            }
        }
        .navigationTitle("Scene")
    }
}
