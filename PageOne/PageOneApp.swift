import SwiftUI
import FBSDKCoreKit
import AppTrackingTransparency
import AdSupport

@main
struct PageOneApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        // Initialize Facebook SDK
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            didFinishLaunchingWithOptions: nil
        )
        
        #if DEBUG
        // Initialize SKAdTestManager for postback testing
        if #available(iOS 16.0, *) {
            _ = SKAdTestManager.shared
            print("🧪 SKAdTestManager initialized for postback testing")
        }
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(.light) // Force light mode only
                .onAppear {
                    // Request tracking permission after a short delay to avoid interrupting initial UI
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        requestTrackingPermission()
                    }
                }
                .onOpenURL { url in
                    // Handle Facebook URL schemes
                    ApplicationDelegate.shared.application(
                        UIApplication.shared,
                        open: url,
                        sourceApplication: nil,
                        annotation: [UIApplication.OpenURLOptionsKey.annotation]
                    )
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    // Track app activation events
                    AppEvents.shared.activateApp()
                }
        }
    }
    
    private func requestTrackingPermission() {
        // Check if we're on iOS 14.5 or later
        guard #available(iOS 14.5, *) else {
            // For older iOS versions, enable Facebook tracking
            enableFacebookTracking()
            return
        }
        
        // Request App Tracking Transparency permission
        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("ATT: Tracking authorized")
                    self.enableFacebookTracking()
                case .denied:
                    print("ATT: Tracking denied")
                    self.disableFacebookTracking()
                case .restricted:
                    print("ATT: Tracking restricted")
                    self.disableFacebookTracking()
                case .notDetermined:
                    print("ATT: Tracking not determined")
                    self.disableFacebookTracking()
                @unknown default:
                    print("ATT: Unknown status")
                    self.disableFacebookTracking()
                }
            }
        }
    }
    
    private func enableFacebookTracking() {
        // Enable Facebook SDK tracking features
        Settings.shared.isAdvertiserTrackingEnabled = true
        Settings.shared.isAutoLogAppEventsEnabled = true
        Settings.shared.isAdvertiserIDCollectionEnabled = true
        print("Facebook tracking enabled")
    }
    
    private func disableFacebookTracking() {
        // Disable Facebook SDK tracking features
        Settings.shared.isAdvertiserTrackingEnabled = false
        Settings.shared.isAutoLogAppEventsEnabled = false
        Settings.shared.isAdvertiserIDCollectionEnabled = false
        print("Facebook tracking disabled")
    }
}
