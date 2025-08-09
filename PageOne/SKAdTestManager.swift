import Foundation
import StoreKit
import StoreKitTest

#if DEBUG
/// Manager for testing SKAdNetwork postbacks using StoreKitTest framework
@available(iOS 16.0, *)
class SKAdTestManager {
    
    /// Shared instance for easy access throughout the app
    static let shared = SKAdTestManager()
    
    /// Test session for managing postbacks
    private var testSession: SKAdTestSession?
    
    /// Test postback for simulating ad attribution
    private var testPostback: SKAdTestPostback?
    
    private init() {
        setupTestSession()
        createTestPostback()
        configureTestSession()
    }
    
    /// Sets up the test session for postbacks
    private func setupTestSession() {
        print("🧪 Setting up SKAdTestSession for postback testing")
        
        // Create test session with impression
        testSession = SKAdTestSession()
        
        if testSession != nil {
            print("✅ SKAdTestSession created successfully")
        } else {
            print("❌ Failed to create SKAdTestSession")
        }
    }
    
    /// Creates a test postback with proper parameters for SKAdNetwork v4
    private func createTestPostback() {
        print("🧪 Creating SKAdTestPostback with v4 parameters")
        
        guard let session = testSession else {
            print("❌ Cannot create test postback - test session not available")
            return
        }
        
        // Create test postback with all required parameters
        testPostback = SKAdTestPostback(
            version: .version4_0,                           // SKAdNetwork version 4
            adNetworkIdentifier: "linkrunner.network.test", // Test ad network identifier (lowercased)
            sourceIdentifier: 1234,                        // 4-digit campaign identifier
            appStoreItemIdentifier: 123456789,             // App Store item ID of advertised app
            sourceAppStoreItemIdentifier: 0,               // Source app Store ID (0 for test environment)
            sourceDomain: "test.linkrunner.com",           // Source domain
            fidelityType: 1,                               // 1 = StoreKit-rendered ad or web ad
            isRedownload: false,                           // Not a redownload
            didWin: true,                                  // This ad network won the attribution
            postbackURL: URL(string: "https://linkrunner-skan.com")! // Your postback URL
        )
        
        if testPostback != nil {
            print("✅ SKAdTestPostback created successfully")
            print("   - Version: 4.0")
            print("   - Ad Network ID: linkrunner.network.test")
            print("   - Campaign ID: 1234") 
            print("   - App Store ID: 123456789")
            print("   - Did Win: true")
            print("   - Postback URL: https://linkrunner-skan.com")
        } else {
            print("❌ Failed to create SKAdTestPostback")
        }
    }
    
    /// Configures the test session with the test postback
    private func configureTestSession() {
        print("🧪 Configuring test session with postbacks")
        
        guard let session = testSession,
              let postback = testPostback else {
            print("❌ Cannot configure test session - missing session or postback")
            return
        }
        
        // Set the test postbacks array
        session.setPostbacks([postback])
        print("✅ Test postbacks set in session")
    }
    
    /// Flushes postbacks to trigger sending them to the server
    /// This should be called after updateConversionValue operations
    func flushPostbacks() {
        print("🧪 Flushing test postbacks to server")
        
        guard let session = testSession else {
            print("❌ Cannot flush postbacks - test session not available")
            return
        }
        
        // Flush postbacks and handle responses
        session.flushPostbacks { responses in
            print("📡 Postback flush completed with \(responses.count) responses")
            
            for (index, response) in responses.enumerated() {
                print("📡 Response \(index + 1):")
                print("   - Status Code: \(response.statusCode)")
                print("   - URL: \(response.url?.absoluteString ?? "Unknown")")
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("   - Headers: \(httpResponse.allHeaderFields)")
                }
                
                // Log success/failure
                if 200...299 ~= response.statusCode {
                    print("   ✅ Postback sent successfully")
                } else {
                    print("   ❌ Postback failed with status: \(response.statusCode)")
                }
            }
        }
    }
    
    /// Registers the app for ad network attribution in test environment
    func registerAppForAdNetworkAttributionTest() {
        print("🧪 Registering app for ad network attribution (test mode)")
        
        // This call is needed to register the test postback
        SKAdNetwork.registerAppForAdNetworkAttribution()
        print("✅ App registered for ad network attribution (test mode)")
    }
    
    /// Updates conversion value and immediately flushes postbacks for testing
    func updateConversionValueAndFlush(_ conversionValue: Int) {
        print("🧪 Test: Updating conversion value to \(conversionValue) and flushing postbacks")
        
        // Update conversion value first
        if #available(iOS 16.1, *) {
            SKAdNetwork.updatePostbackConversionValue(conversionValue) { [weak self] error in
                if let error = error {
                    print("❌ Test conversion value update failed: \(error)")
                } else {
                    print("✅ Test conversion value updated to \(conversionValue)")
                    // Flush postbacks after successful update
                    DispatchQueue.main.async {
                        self?.flushPostbacks()
                    }
                }
            }
        } else if #available(iOS 15.4, *) {
            SKAdNetwork.updatePostbackConversionValue(conversionValue) { [weak self] error in
                if let error = error {
                    print("❌ Test conversion value update failed: \(error)")
                } else {
                    print("✅ Test conversion value updated to \(conversionValue)")
                    // Flush postbacks after successful update
                    DispatchQueue.main.async {
                        self?.flushPostbacks()
                    }
                }
            }
        } else if #available(iOS 14.0, *) {
            SKAdNetwork.updateConversionValue(conversionValue)
            print("✅ Test conversion value updated to \(conversionValue)")
            // Flush postbacks immediately for synchronous call
            flushPostbacks()
        }
    }
    
    /// Diagnostic method to check test session status
    func diagnostics() {
        print("🔍 SKAdTestManager Diagnostics:")
        print("   - Test Session: \(testSession != nil ? "✅ Available" : "❌ Not Available")")
        print("   - Test Postback: \(testPostback != nil ? "✅ Available" : "❌ Not Available")")
        
        if let postback = testPostback {
            print("   - Postback URL: \(postback.postbackURL.absoluteString)")
            print("   - Ad Network ID: \(postback.adNetworkIdentifier)")
            print("   - Did Win: \(postback.didWin)")
        }
    }
}
#endif
