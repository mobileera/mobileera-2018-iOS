import UIKit
import GoogleMaps
import Firebase
import FirebaseDatabase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    public static let domain = "https://mobileera.rocks"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        GMSServices.provideAPIKey("AIzaSyBsjUHSxEaVtIS90m7h8E030QmTo-U0c0Y")
        return true
    }
}

