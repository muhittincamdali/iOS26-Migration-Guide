import SwiftUI

/// The SwiftUI Liquid Glass APIs of iOS 26 on a custom control: a glass effect, a container that
/// lets nearby glass shapes blend and morph, and the two glass button styles. Standard bars and
/// controls need none of this: they adopt the material when the app is built with the iOS 26 SDK.
struct GlassScreen: View {
    @State private var isExpanded = ProcessInfo.processInfo.arguments.contains("-expanded")
    @Namespace private var glass

    private let tools = ["pencil", "eraser", "lasso", "paintbrush"]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.02, green: 0.18, blue: 0.42), Color(red: 0.25, green: 0.62, blue: 0.95)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Text("Content stays below; glass is for the controls that float above it.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(20)
                    .glassEffect(.regular.tint(.blue.opacity(0.25)), in: .rect(cornerRadius: 24))

                GlassEffectContainer(spacing: 16) {
                    HStack(spacing: 16) {
                        Button {
                            withAnimation(.smooth) { isExpanded.toggle() }
                        } label: {
                            Image(systemName: isExpanded ? "xmark" : "paintpalette")
                                .frame(width: 52, height: 52)
                        }
                        .glassEffect(.regular.interactive())
                        .glassEffectID("toggle", in: glass)
                        .accessibilityLabel(isExpanded ? "Hide tools" : "Show tools")

                        if isExpanded {
                            ForEach(tools, id: \.self) { tool in
                                Image(systemName: tool)
                                    .frame(width: 52, height: 52)
                                    .glassEffect(.regular.interactive())
                                    .glassEffectID(tool, in: glass)
                            }
                        }
                    }
                    .font(.title3)
                }

                HStack(spacing: 16) {
                    Button("Glass") {}
                        .buttonStyle(.glass)
                    Button("Prominent glass") {}
                        .buttonStyle(.glassProminent)
                }
                .controlSize(.large)
            }
            .padding(24)
        }
        .navigationTitle("Liquid Glass")
    }
}
