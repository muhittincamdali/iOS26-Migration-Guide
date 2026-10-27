import SwiftUI

struct SettingsView: View {
    @State private var notificationsOn = false
    @State private var showsHelp = false

    var body: some View {
        NavigationView {
            Form {
                Toggle("Notifications", isOn: $notificationsOn)
                    .onChange(of: notificationsOn) { isOn in
                        print("Notifications:", isOn)
                    }
                Text("Version ") + Text("2.0").bold()
            }
            .navigationBarTitle("Settings")
            .alert(isPresented: $showsHelp) {
                Alert(title: Text("Help"))
            }
        }
    }
}
