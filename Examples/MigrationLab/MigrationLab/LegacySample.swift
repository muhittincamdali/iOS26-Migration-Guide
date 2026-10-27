/// Code as it was often written before iOS 26: the text the scanner screen starts with. It is a
/// string, so scanning this project does not report it.
enum LegacySample {
    static let source = #"""
    @UIApplicationMain
    final class AppDelegate: UIResponder, UIApplicationDelegate {
        var window: UIWindow?

        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.makeKeyAndVisible()
            return true
        }

        func applicationDidBecomeActive(_ application: UIApplication) {
            application.applicationIconBadgeNumber = 0
        }
    }

    struct SettingsView: View {
        @State private var query = ""

        var body: some View {
            NavigationView {
                TextField("Search", text: $query)
                    .onChange(of: query) { newValue in search(newValue) }
                Text("Version ") + Text("2.0").bold()
            }
        }
    }
    """#
}
