import Foundation
import StoreKit

/// Centralized manager for SKAdNetwork (SKAN) conversion tracking
class SKANManager {
    
    /// Shared instance for easy access throughout the app
    static let shared = SKANManager()
    
    private init() {}
    
    /// Conversion value mapping for different user actions
    private enum ConversionValue: Int {
        case noteCreated = 1
        case firstNoteCreated = 2
        case noteEdited = 3
        case multipleNotesCreated = 4
        case activeUser = 5  // User who creates 5+ notes
        
        var coarseValue: SKAdNetwork.CoarseConversionValue {
            switch self {
            case .noteCreated, .noteEdited:
                return .low
            case .firstNoteCreated, .multipleNotesCreated:
                return .medium
            case .activeUser:
                return .high
            }
        }
    }
    
    /// Tracks SKAN conversion for note creation
    func trackNoteCreated(isFirstNote: Bool = false) {
        let value: ConversionValue = isFirstNote ? .firstNoteCreated : .noteCreated
        trackConversion(value: value, action: isFirstNote ? "first_note_created" : "note_created")
    }
    
    /// Tracks SKAN conversion for note editing
    func trackNoteEdited() {
        trackConversion(value: .noteEdited, action: "note_edited")
    }
    
    /// Tracks SKAN conversion for active users (multiple notes)
    func trackActiveUser() {
        trackConversion(value: .activeUser, action: "active_user")
    }
    
    /// Tracks app install/first open with conversion value 1 (called automatically on init)
    private func trackAppInstall() {
        // Check if we've already sent the install postback
        let hasTrackedInstall = UserDefaults.standard.bool(forKey: "SKANInstallTracked")
        
        guard !hasTrackedInstall else {
            print("ℹ️ SKAN install already tracked, skipping")
            return
        }
        
        print("🎯 Tracking SKAN app install/first open")
        
        // Use conversion value 1 for install (following Branch SDK pattern)
        // Flag will be set in trackInstallConversion completion handlers
        trackInstallConversion(value: 1, action: "app_install")
    }
    
    /// Tracks install conversion with proper iOS version handling (like Branch SDK)
    private func trackInstallConversion(value: Int, action: String) {
        guard shouldAttemptSKANUpdate() else {
            print("⚠️ SKAN install update skipped - outside valid window for \(action)")
            return
        }
        
        let currentWindow = calculateCurrentSKANWindow()
        print("🎯 Tracking SKAN install conversion - Action: \(action), Value: \(value), Window: \(currentWindow)")
        
        // For install, lock window to secure the attribution
        let shouldLockWindow = true
        
        // iOS 16.1+ - SKAN 4.0 with coarse value and lock window
        if #available(iOS 16.1, *) {
            SKAdNetwork.updatePostbackConversionValue(
                value,
                coarseValue: .low,  // Install is typically low value
                lockWindow: shouldLockWindow
            ) { error in
                if let error = error {
                    print("❌ SKAN 4.0 install postback failed for \(action): \(error)")
                } else {
                    print("✅ SKAN 4.0 install postback successful for \(action) with value \(value), locked: \(shouldLockWindow)")
                    // Mark as tracked only on success
                    UserDefaults.standard.set(true, forKey: "SKANInstallTracked")
                    
                    #if DEBUG
                    // Flush test postbacks after successful install conversion
                    if #available(iOS 16.0, *) {
                        SKAdTestManager.shared.flushPostbacks()
                    }
                    #endif
                }
            }
        }
        // iOS 15.4+ - SKAN 3.0 with postback and completion handler
        else if #available(iOS 15.4, *) {
            SKAdNetwork.updatePostbackConversionValue(value) { error in
                if let error = error {
                    print("❌ SKAN 3.0 install postback failed for \(action): \(error)")
                } else {
                    print("✅ SKAN 3.0 install postback successful for \(action) with value \(value)")
                    // Mark as tracked only on success
                    UserDefaults.standard.set(true, forKey: "SKANInstallTracked")
                    
                    #if DEBUG
                    // Flush test postbacks after successful install conversion
                    if #available(iOS 16.0, *) {
                        SKAdTestManager.shared.flushPostbacks()
                    }
                    #endif
                }
            }
        }
        // iOS 14.0+ - Original SKAN API (no postback, just conversion value)
        else if #available(iOS 14.0, *) {
            SKAdNetwork.updateConversionValue(value)
            print("✅ SKAN 2.0 install conversion value updated for \(action) with value \(value)")
            // Mark as tracked immediately for synchronous call
            UserDefaults.standard.set(true, forKey: "SKANInstallTracked")
            
            #if DEBUG
            // Flush test postbacks after install conversion update
            if #available(iOS 16.0, *) {
                SKAdTestManager.shared.flushPostbacks()
            }
            #endif
        } else {
            print("⚠️ SKAN not available on this iOS version")
        }
    }
    
    /// Generic method to track SKAN conversion values
    private func trackConversion(value: ConversionValue, action: String) {
        print("🎯 Tracking SKAN conversion - Action: \(action), Value: \(value.rawValue)")
        
        // Use the latest SKAN API if available (iOS 16.1+)
        if #available(iOS 16.1, *) {
            SKAdNetwork.updatePostbackConversionValue(
                value.rawValue,
                coarseValue: value.coarseValue,
                lockWindow: false
            ) { error in
                if let error = error {
                    print("❌ SKAN conversion update failed for \(action): \(error)")
                } else {
                    print("✅ SKAN conversion successfully updated for \(action) with value \(value.rawValue)")
                }
            }
        } else if #available(iOS 14.0, *) {
            // Fallback to older SKAN API
            SKAdNetwork.updateConversionValue(value.rawValue)
            print("✅ SKAN conversion value updated (legacy API) for \(action) with value \(value.rawValue)")
        } else {
            print("⚠️ SKAN not available on this iOS version")
        }
    }
    
    /// Tracks conversion with custom value (for special cases)
    func trackCustomConversion(value: Int, action: String, coarseValue: SKAdNetwork.CoarseConversionValue = .low) {
        print("🎯 Tracking custom SKAN conversion - Action: \(action), Value: \(value)")
        
        if #available(iOS 16.1, *) {
            SKAdNetwork.updatePostbackConversionValue(
                value,
                coarseValue: coarseValue,
                lockWindow: false
            ) { error in
                if let error = error {
                    print("❌ Custom SKAN conversion update failed for \(action): \(error)")
                } else {
                    print("✅ Custom SKAN conversion successfully updated for \(action) with value \(value)")
                }
            }
        } else if #available(iOS 14.0, *) {
            SKAdNetwork.updateConversionValue(value)
            print("✅ Custom SKAN conversion value updated (legacy API) for \(action) with value \(value)")
        } else {
            print("⚠️ SKAN not available on this iOS version")
        }
    }
} 