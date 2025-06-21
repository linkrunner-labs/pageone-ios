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