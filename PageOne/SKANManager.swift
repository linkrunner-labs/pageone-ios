import Foundation
import StoreKit

/// Centralized manager for SKAdNetwork (SKAN) conversion tracking
class SKANManager {
    
    /// Shared instance for easy access throughout the app
    static let shared = SKANManager()
    
    /// Install date for SKAN window calculations
    private let installDate: Date
    
    private init() {
        // Get or set install date for SKAN window calculations
        if let storedInstallDate = UserDefaults.standard.object(forKey: "SKANInstallDate") as? Date {
            self.installDate = storedInstallDate
        } else {
            self.installDate = Date()
            UserDefaults.standard.set(self.installDate, forKey: "SKANInstallDate")
        }
        
        // Register app for SKAdNetwork attribution on initialization
        registerAppForAdNetworkAttribution()
        
        // Track app install/first open with conversion value 1 (following Branch pattern)
        trackAppInstall()
    }
    
    /// Registers the app for SKAdNetwork attribution (iOS 14.0-15.4 only)
    private func registerAppForAdNetworkAttribution() {
        if #available(iOS 16.0, *) {
            // registerAppForAdNetworkAttribution is not available on iOS 16+
            print("ℹ️ SKAdNetwork registration not needed on iOS 16+ (automatic)")
        } else if #available(iOS 14.0, *) {
            // Only call on iOS 14.0-15.4 where it's valid
            SKAdNetwork.registerAppForAdNetworkAttribution()
            print("✅ App registered for SKAdNetwork attribution (iOS 14-15)")
        } else {
            print("⚠️ SKAdNetwork registration not available on this iOS version")
        }
    }
    
    /// SKAN measurement windows
    private enum SKANWindow: Int {
        case first = 0      // 0-2 days
        case second = 1     // 2-7 days  
        case third = 2      // 7-35 days
        case invalid = -1   // Beyond 35 days
    }
    
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
        
        // Mark as tracked before making the call to prevent duplicates
        UserDefaults.standard.set(true, forKey: "SKANInstallTracked")
        
        // Use conversion value 1 for install (following Branch SDK pattern)
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
                }
            }
        }
        // iOS 14.0+ - Original SKAN API (no postback, just conversion value)
        else if #available(iOS 14.0, *) {
            SKAdNetwork.updateConversionValue(value)
            print("✅ SKAN 2.0 install conversion value updated for \(action) with value \(value)")
        } else {
            print("⚠️ SKAN not available on this iOS version")
        }
    }
    
    /// Generic method to track SKAN conversion values
    private func trackConversion(value: ConversionValue, action: String) {
        guard shouldAttemptSKANUpdate() else {
            print("⚠️ SKAN update skipped - outside valid window for \(action)")
            return
        }
        
        let currentWindow = calculateCurrentSKANWindow()
        print("🎯 Tracking SKAN conversion - Action: \(action), Value: \(value.rawValue), Window: \(currentWindow)")
        
        // Determine lockWindow based on window and action importance
        let shouldLockWindow = (currentWindow == .first && value.rawValue >= 2) || 
                              (currentWindow == .second && value.rawValue >= 2) ||
                              (currentWindow == .third && value.rawValue >= 2)
        
        // iOS 16.1+ - SKAN 4.0 with coarse value and lock window
        if #available(iOS 16.1, *) {
            SKAdNetwork.updatePostbackConversionValue(
                value.rawValue,
                coarseValue: value.coarseValue,
                lockWindow: shouldLockWindow
            ) { error in
                if let error = error {
                    print("❌ SKAN 4.0 postback update failed for \(action): \(error)")
                } else {
                    print("✅ SKAN 4.0 postback successfully updated for \(action) with value \(value.rawValue), lockWindow: \(shouldLockWindow)")
                }
            }
        }
        // iOS 15.4+ - SKAN 3.0 with postback and completion handler
        else if #available(iOS 15.4, *) {
            SKAdNetwork.updatePostbackConversionValue(value.rawValue) { error in
                if let error = error {
                    print("❌ SKAN 3.0 postback update failed for \(action): \(error)")
                } else {
                    print("✅ SKAN 3.0 postback successfully updated for \(action) with value \(value.rawValue)")
                }
            }
        }
        // iOS 14.0+ - Original SKAN API (no postback, just conversion value)
        else if #available(iOS 14.0, *) {
            SKAdNetwork.updateConversionValue(value.rawValue)
            print("✅ SKAN 2.0 conversion value updated for \(action) with value \(value.rawValue)")
        } else {
            print("⚠️ SKAN not available on this iOS version")
        }
    }
    
    /// Calculates which SKAN window the app is currently in
    private func calculateCurrentSKANWindow() -> SKANWindow {
        let now = Date()
        let timeSinceInstall = now.timeIntervalSince(installDate)
        
        let firstWindowDuration: TimeInterval = 2 * 24 * 3600  // 2 days
        let secondWindowDuration: TimeInterval = 7 * 24 * 3600 // 7 days  
        let thirdWindowDuration: TimeInterval = 35 * 24 * 3600 // 35 days
        
        if timeSinceInstall <= firstWindowDuration {
            return .first
        } else if timeSinceInstall <= secondWindowDuration {
            return .second
        } else if timeSinceInstall <= thirdWindowDuration {
            return .third
        } else {
            return .invalid
        }
    }
    
    /// Checks if SKAN updates should be attempted based on current window
    private func shouldAttemptSKANUpdate() -> Bool {
        let currentWindow = calculateCurrentSKANWindow()
        return currentWindow != .invalid
    }
    
    /// Tracks conversion with custom value (for special cases)
    func trackCustomConversion(value: Int, action: String, coarseValue: SKAdNetwork.CoarseConversionValue = .low, lockWindow: Bool = false) {
        guard shouldAttemptSKANUpdate() else {
            print("⚠️ Custom SKAN update skipped - outside valid window for \(action)")
            return
        }
        
        let currentWindow = calculateCurrentSKANWindow()
        print("🎯 Tracking custom SKAN conversion - Action: \(action), Value: \(value), Window: \(currentWindow)")
        
        // iOS 16.1+ - SKAN 4.0 with coarse value and lock window
        if #available(iOS 16.1, *) {
            SKAdNetwork.updatePostbackConversionValue(
                value,
                coarseValue: coarseValue,
                lockWindow: lockWindow
            ) { error in
                if let error = error {
                    print("❌ Custom SKAN 4.0 postback update failed for \(action): \(error)")
                } else {
                    print("✅ Custom SKAN 4.0 postback successfully updated for \(action) with value \(value), lockWindow: \(lockWindow)")
                }
            }
        }
        // iOS 15.4+ - SKAN 3.0 with postback and completion handler
        else if #available(iOS 15.4, *) {
            SKAdNetwork.updatePostbackConversionValue(value) { error in
                if let error = error {
                    print("❌ Custom SKAN 3.0 postback update failed for \(action): \(error)")
                } else {
                    print("✅ Custom SKAN 3.0 postback successfully updated for \(action) with value \(value)")
                }
            }
        }
        // iOS 14.0+ - Original SKAN API (no postback, just conversion value)
        else if #available(iOS 14.0, *) {
            SKAdNetwork.updateConversionValue(value)
            print("✅ Custom SKAN 2.0 conversion value updated for \(action) with value \(value)")
        } else {
            print("⚠️ SKAN not available on this iOS version")
        }
    }
} 