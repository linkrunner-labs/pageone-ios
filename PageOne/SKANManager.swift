import Foundation
import StoreKit
// import AdAttributionKit  // Commented out - migrating back to StoreKit

/// Centralized manager for SKAdNetwork (SKAN) conversion tracking
class SKANManager {
    
    /// Shared instance for easy access throughout the app
    static let shared = SKANManager()
    
    /// Track if development impression has been created
    private var impressionCreated = false
    
    /// Track impression creation task to ensure it completes before conversions
    private var impressionTask: Task<Void, Error>?
    
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
    
    /// Generic method to track SKAN conversion values using StoreKit
    private func trackConversion(value: ConversionValue, action: String) {
        print("🎯 Tracking SKAN conversion - Action: \(action), Value: \(value.rawValue)")
        
        // Use StoreKit SKAdNetwork
        if #available(iOS 16.1, *) {
            SKAdNetwork.updatePostbackConversionValue(
                value.rawValue,
                coarseValue: value.coarseValue,
                lockWindow: true
            ) { error in
                if let error = error {
                    print("❌ SKAN conversion update failed for \(action): \(error)")
                } else {
                    print("✅ SKAN conversion successfully updated for \(action) with value \(value.rawValue)")
                }
            }
        } else if #available(iOS 14.0, *) {
            SKAdNetwork.updateConversionValue(value.rawValue)
            print("✅ SKAN conversion value updated (legacy API) for \(action) with value \(value.rawValue)")
        }
        
        // Commented out AdAttributionKit implementation
        // if #available(iOS 18.0, *) {
        //     Task {
        //         do {
        //             // Ensure impression is created first
        //             try await ensureImpressionCreated()
        //             
        //             // Create PostbackUpdate with fine conversion value (iOS 18.0+)
        //             let postbackUpdate = PostbackUpdate(
        //                 fineConversionValue: value.rawValue,
        //                 lockPostback: true,
        //                 coarseConversionValue: value.coarseValue,
        //                 conversionTypes: [.install]
        //             )
        //             
        //             // Now track the conversion
        //             try await Postback.updateConversionValue(postbackUpdate)
        //             print("✅ AdAttributionKit conversion successfully updated for \(action) with value \(value.rawValue)")
        //         } catch {
        //             print("❌ AdAttributionKit conversion update failed for \(action): \(error)")
        //         }
        //     }
        // }
    }
    
    /// Tracks conversion with custom value (for special cases) using StoreKit
    func trackCustomConversion(value: Int, action: String) {
        print("🎯 Tracking custom SKAN conversion - Action: \(action), Value: \(value)")
        
        // Use StoreKit SKAdNetwork
        if #available(iOS 16.1, *) {
            SKAdNetwork.updatePostbackConversionValue(
                value,
                coarseValue: .medium,  // Default to medium for custom conversions
                lockWindow: true
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
        }
        
        // Commented out AdAttributionKit implementation
        // if #available(iOS 18.0, *) {
        //     Task {
        //         do {
        //             // Ensure impression is created first
        //             try await ensureImpressionCreated()
        //             
        //             // Create PostbackUpdate with custom fine conversion value (iOS 18.0+)
        //             let postbackUpdate = PostbackUpdate(
        //                 fineConversionValue: value,
        //                 lockPostback: true,
        //                 coarseConversionValue: .medium,
        //                 conversionTypes: [.install]
        //             )
        //             
        //             // Now track the custom conversion
        //             try await Postback.updateConversionValue(postbackUpdate)
        //             print("✅ Custom AdAttributionKit conversion successfully updated for \(action) with value \(value)")
        //         } catch {
        //             print("❌ Custom AdAttributionKit conversion update failed for \(action): \(error)")
        //         }
        //     }
        // }
    }
    
    // Commented out AdAttributionKit impression management
    // /// Ensure impression is created before tracking conversions
    // @available(iOS 17.4, *)
    // private func ensureImpressionCreated() async throws {
    //     guard !impressionCreated else {
    //         print("ℹ️ Impression already created, proceeding with conversion tracking")
    //         return
    //     }
    //     
    //     // If impression task is already running, wait for it to complete
    //     if let existingTask = impressionTask {
    //         print("⏳ Waiting for existing impression creation to complete...")
    //         do {
    //             try await existingTask.value
    //             return
    //         } catch {
    //             print("❌ Existing impression task failed: \(error)")
    //             // Continue to try creating a new impression
    //         }
    //     }
    //     
    //     // Create new impression
    //     print("🎯 Creating impression before conversion tracking...")
    //     impressionTask = Task {
    //         try await createAdAttributionKitDevelopmentImpression()
    //     }
    //     
    //     try await impressionTask!.value
    // }
    
    /// Create a development impression using StoreKit
    func createDevelopmentImpression() {
        if #available(iOS 14.6, *) {
            Task {
                await createStoreKitDevelopmentImpression()
            }
        } else {
            print("⚠️ StoreKit impression creation not available on this iOS version (requires iOS 14.6+)")
        }
        
        // Commented out AdAttributionKit implementation
        // if #available(iOS 17.4, *) {
        //     impressionTask = Task {
        //         try await createAdAttributionKitDevelopmentImpression()
        //     }
        // }
    }
    
    /// Internal method to create StoreKit development impression
    @available(iOS 14.6, *)
    private func createStoreKitDevelopmentImpression() async {
        guard !impressionCreated else {
            print("Development impression already created")
            return
        }
        
        do {
            // Create impression with source App Store identifier = 0 for development
            let impression = SKAdImpression(
                sourceAppStoreItemIdentifier: 0,  // This makes it a development impression
                advertisedAppStoreItemIdentifier: 6747420629, // Your app's App Store ID
                adNetworkIdentifier: "example.skadnetwork", // Use a test network ID
                adCampaignIdentifier: 739874,
                adImpressionIdentifier: UUID().uuidString,
                timestamp: 974958093749,
                signature: "test-signature",
                version: "2.2"
            )
            
            SKAdNetwork.startImpression(impression) { error in
                if let error = error {
                    print("❌ Error starting StoreKit impression: \(error)")
                    if let nsError = error as NSError? {
                        print("Error details:")
                        print("- Domain: \(nsError.domain)")
                        print("- Code: \(nsError.code)")
                        print("- Description: \(nsError.localizedDescription)")
                        print("- UserInfo: \(nsError.userInfo)")
                    }
                } else {
                    print("✅ StoreKit development impression started successfully")
                    self.impressionCreated = true
                    
                    // Send first conversion value after 1 minute
                    DispatchQueue.main.asyncAfter(deadline: .now() + 60.0) {
                        print("⏰ Sending first conversion value 1 minute after impression...")
                        self.trackNoteCreated(isFirstNote: true)
                    }
                }
            }
        } catch {
            print("❌ Failed to create StoreKit impression: \(error)")
        }
    }
    
    /// Alternative method to create impression for testing different scenarios
    @available(iOS 14.6, *)
    func createTestImpression(appStoreId: NSNumber = 6747420629) {
        let impression = SKAdImpression(
            sourceAppStoreItemIdentifier: 0,  // Development impression
            advertisedAppStoreItemIdentifier: appStoreId,
            adNetworkIdentifier: "development.skadnetwork",
            adCampaignIdentifier: 739874,
            adImpressionIdentifier: UUID().uuidString,
            timestamp: 879866564576,
            signature: "test-signature",
            version: "2.2"
        )
        
        SKAdNetwork.startImpression(impression) { error in
            if let error = error {
                print("❌ Test impression failed: \(error)")
            } else {
                print("✅ Test impression created for App Store ID: \(appStoreId)")
            }
        }
    }
    
    // Commented out AdAttributionKit implementation
    // /// Internal method to create AdAttributionKit development impression with JWS
    // @available(iOS 17.4, *)
    // private func createAdAttributionKitDevelopmentImpression() async throws {
    //     guard !impressionCreated else {
    //         print("Development impression already created")
    //         return
    //     }
    //     
    //     // Generate JWS payload for development impression
    //     print("🔐 Generating JWS payload for development impression...")
    //     let jwsPayload = generateDevelopmentJWSPayload()
    //     
    //     if jwsPayload.isEmpty {
    //         let error = NSError(domain: "JWSError", code: -1, userInfo: [NSLocalizedDescriptionKey: "JWS payload generation failed"])
    //         print("❌ JWS payload generation failed")
    //         throw error
    //     }
    //     
    //     print("✅ JWS payload generated successfully (\(jwsPayload.count) characters)")
    //     
    //     // Create AppImpression with the JWS
    //     print("📱 Creating AppImpression with JWS...")
    //     let impression: AppImpression
    //     do {
    //         impression = try await AppImpression(compactJWS: jwsPayload)
    //         print("✅ AppImpression created successfully")
    //     } catch {
    //         print("❌ Failed to create AppImpression: \(error)")
    //         if let nsError = error as NSError? {
    //             print("📋 AppImpression Error Details:")
    //             print("   - Domain: \(nsError.domain)")
    //             print("   - Code: \(nsError.code)")
    //             print("   - Description: \(nsError.localizedDescription)")
    //             print("   - UserInfo: \(nsError.userInfo)")
    //         }
    //         print("🔧 Debug: JWS that failed AppImpression creation:")
    //         print("   JWS: \(jwsPayload.prefix(200))...")
    //         throw error
    //     }
    //     
    //     // Start the impression
    //     print("🚀 Starting AdAttributionKit impression...")
    //     do {
    // //            try await impression.startImpression()
    //         print("✅ AdAttributionKit development impression started successfully")
    //         impressionCreated = true
    //         
    //         // Send test conversion value after 2 seconds
    //         DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
    //             print("⏰ Sending test conversion value 2 seconds after impression...")
    //             self.trackNoteCreated(isFirstNote: true)
    //         }
    //         
    //     } catch {
    //         print("❌ Failed to start AdAttributionKit impression: \(error)")
    //         if let nsError = error as NSError? {
    //             print("📋 Start Impression Error Details:")
    //             print("   - Domain: \(nsError.domain)")
    //             print("   - Code: \(nsError.code)")
    //             print("   - Description: \(nsError.localizedDescription)")
    //             print("   - UserInfo: \(nsError.userInfo)")
    //             print("   - Recovery Suggestion: \(nsError.localizedRecoverySuggestion ?? "None")")
    //             print("   - Failure Reason: \(nsError.localizedFailureReason ?? "Unknown")")
    //             
    //             // Check for specific error codes
    //             switch nsError.code {
    //             case -1:
    //                 print("🔍 Possible invalid JWS signature")
    //             case -2:
    //                 print("🔍 Possible network connectivity issue")
    //             case -3:
    //                 print("🔍 Possible AdAttributionKit configuration error")
    //             default:
    //                 print("🔍 Unrecognized error code: \(nsError.code)")
    //             }
    //         }
    //         throw error
    //     }
    // }
    
    /// Generate JWS payload for development impression
    /// Sets publisher item identifier to 0 for development testing
    /// Implements: ASCII(BASE64URL(UTF8(JWS Protected Header)) || '.' || BASE64URL(JWS Payload)) then ES256 sign
    @available(iOS 17.4, *)
    private func generateDevelopmentJWSPayload() -> String {
        // JWS Protected Header (matching working example)
        let header = [
            "kid": "apple-development-identifier/1",
            "alg": "ES256"
        ]
        
        // JWS Payload for development impression (matching working example format)
        let payload = [
            "advertised-item-identifier": 6747420629,  // Your app's App Store ID
            "ad-network-identifier": "development.adattributionkit",
            "impression-type": "app-impression",
            "timestamp": Int(Date().timeIntervalSince1970 * 1000),
            "publisher-item-identifier": 0,  // 0 for development
            "impression-identifier": UUID().uuidString,
            "source-identifier": 0
        ] as [String: Any]
        
        // Convert to JSON
        guard let headerData = try? JSONSerialization.data(withJSONObject: header),
              let payloadData = try? JSONSerialization.data(withJSONObject: payload) else {
            print("❌ Failed to serialize JWS components for development impression")
            print("📋 Header: \(header)")
            print("📋 Payload: \(payload)")
            return ""
        }
        
        // Base64URL encode header and payload
        let headerB64URL = base64URLEncode(headerData)
        let payloadB64URL = base64URLEncode(payloadData)
        
        // Create signing input: ASCII(BASE64URL(header) + '.' + BASE64URL(payload))
        let signingInput = "\(headerB64URL).\(payloadB64URL)"
        let signingInputData = signingInput.data(using: .ascii)!
        
        // Sign with ES256 using ad network registration private key
        do {
            let privateKey = try loadAdNetworkPrivateKey()
            let signature = try signWithES256(signingInputData: signingInputData, privateKey: privateKey)
            let signatureB64URL = base64URLEncode(signature)
        
            // Final JWS: header.payload.signature
            let jws = "\(headerB64URL).\(payloadB64URL).\(signatureB64URL)"
            print("🔐 Generated development JWS: \(jws)")
            print("📝 Signing input: \(signingInput)")
            
            return jws
        } catch {
            print("❌ ES256 signing failed for development JWS: \(error)")
            if let nsError = error as NSError? {
                print("📋 JWS Signing Error Details:")
                print("   - Domain: \(nsError.domain)")
                print("   - Code: \(nsError.code)")
                print("   - Description: \(nsError.localizedDescription)")
                
                if nsError.domain == "JWSError" {
                    print("🔍 Private key loading or signing issue")
                    print("💡 Check if ad network private key is properly configured")
                }
            }
            return ""
        }
    }
    
    /// Alternative method to create AdAttributionKit impression for testing
    @available(iOS 17.4, *)
    func createTestAdAttributionImpression(appStoreId: Int = 6747420629) async {
        print("🧪 Starting test impression creation for App Store ID: \(appStoreId)")
        
        do {
            // Generate test JWS payload
            print("🔐 Generating test JWS payload...")
            let jwsPayload = generateTestJWSPayload(appStoreId: appStoreId)
            
            if jwsPayload.isEmpty {
                print("❌ Test JWS payload generation failed")
                return
            }
            
            print("✅ Test JWS payload generated (\(jwsPayload.count) characters)")
            
            // Create test impression
            print("📱 Creating test AppImpression...")
            // let payload = "eyJraWQiOiJleGFtcGxlLmFkYXR0cmlidXRpb25raXQiLCJhbGciOiJFUzI1NiJ9.eyJhZHZlcnRpc2VkLWl0ZW0taWRlbnRpZmllciI6MTEwODE4NzM5MCwiYWQtbmV0d29yay1pZGVudGlmaWVyIjoiZXhhbXBsZS5hZGF0dHJpYnV0aW9ua2l0IiwiaW1wcmVzc2lvbi10eXBlIjoiYXBwLWltcHJlc3Npb24iLCJlbGlnaWJsZS1mb3ItcmUtZW5nYWdlbWVudCI6dHJ1ZSwidGltZXN0YW1wIjoxNzE5NTk5OTU3MjM5LCJwdWJsaXNoZXItaXRlbS1pZGVudGlmaWVyIjo1ODM4NDkyLCJpbXByZXNzaW9uLWlkZW50aWZpZXIiOiI1NDRCOEZBRC0wQUQ1LTQ0MzQtOThCMi0zMjcxMTNBRjg0REIiLCJzb3VyY2UtaWRlbnRpZmllciI6NTIzOX0.zxQ_HcpB7pK6lWOms4LZ8uK3sZu_0S-bPR0My7UY4QlEAYFP-wp5eN1WuHOmNwoPD5cgazpwA3o5xq-fhfpOEQ"
            let impression = try await AppImpression(compactJWS: jwsPayload)
            print("✅ Test AppImpression created successfully")
            
            // Start test impression
            print("🚀 Starting test impression...")
//            try await impression.startImpression()
            print("✅ AdAttributionKit test impression created for App Store ID: \(appStoreId)")
            
        } catch {
            print("❌ AdAttributionKit test impression failed: \(error)")
            if let nsError = error as NSError? {
                print("📋 Test Impression Error Details:")
                print("   - Domain: \(nsError.domain)")
                print("   - Code: \(nsError.code)")
                print("   - Description: \(nsError.localizedDescription)")
                print("   - UserInfo: \(nsError.userInfo)")
                
                // Log test-specific error analysis
                if nsError.domain.contains("AdAttribution") {
                    print("🔍 This is an AdAttributionKit-specific error")
                    print("💡 Check if your app is properly configured for AdAttributionKit")
                } else if nsError.domain == "JWSError" {
                    print("🔍 JWS-related error in test impression")
                    print("💡 Verify JWS format and signing for test payload")
                }
                
                // Log the test JWS for debugging
                print("🔧 Debug: Test JWS payload:")
                let debugJWS = generateTestJWSPayload(appStoreId: appStoreId)
                print("   JWS: \(debugJWS.prefix(150))...")
            }
        }
    }
    
    /// Generate test JWS payload with custom app store ID using proper ES256 signing
    @available(iOS 17.4, *)
    private func generateTestJWSPayload(appStoreId: Int) -> String {
        let header = [
            "kid": "apple-development-identifier/1",
            "alg": "ES256"
        ]
        
        let payload = [
            "advertised-item-identifier": 6747420629,  // Your app's App Store ID
            "ad-network-identifier": "development.adattributionkit",
            "impression-type": "app-impression",
            "timestamp": Int(Date().timeIntervalSince1970 * 1000),
            "publisher-item-identifier": 0,  // 0 for development
            "impression-identifier": UUID().uuidString,
            "source-identifier": 0
        ] as [String: Any]
        
        guard let headerData = try? JSONSerialization.data(withJSONObject: header),
              let payloadData = try? JSONSerialization.data(withJSONObject: payload) else {
            return ""
        }
        
        let headerB64URL = base64URLEncode(headerData)
        let payloadB64URL = base64URLEncode(payloadData)
        let signingInput = "\(headerB64URL).\(payloadB64URL)"
        let signingInputData = signingInput.data(using: .ascii)!
        
        do {
            let privateKey = try loadAdNetworkPrivateKey()
            let signature = try signWithES256(signingInputData: signingInputData, privateKey: privateKey)
            let signatureB64URL = base64URLEncode(signature)
            return "\(headerB64URL).\(payloadB64URL).\(signatureB64URL)"
        } catch {
            print("❌ ES256 signing failed: \(error)")
            return ""
        }
    }
    
    /// Base64URL encoding helper (RFC 7515)
    @available(iOS 17.4, *)
    private func base64URLEncode(_ data: Data) -> String {
        return data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
    /// Load ad network private key from registration
    /// This key should be provided by your ad network during registration process
    @available(iOS 17.4, *)
    private func loadAdNetworkPrivateKey() throws -> SecKey {
        print("🔑 Loading ad network private key...")
        
        // // Option 1: Load from Keychain if stored during ad network registration
        // print("🔍 Attempting to load private key from Keychain...")
        // let keyTag = "com.pageone.adnetwork.registration.privatekey".data(using: .utf8)!
        
        // let query: [String: Any] = [
        //     kSecClass as String: kSecClassKey,
        //     kSecAttrApplicationTag as String: keyTag,
        //     kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
        //     kSecReturnRef as String: true
        // ]
        
        // var keyRef: CFTypeRef?
        // let status = SecItemCopyMatching(query as CFDictionary, &keyRef)
        
        // if status == errSecSuccess, let privateKey = keyRef as? SecKey {
        //     print("✅ Loaded ad network private key from Keychain")
        //     return privateKey
        // } else {
        //     print("⚠️ Failed to load private key from Keychain, status: \(status)")
        // }
        
        // // Option 2: Load from embedded certificate/key file (if you have it)
        // print("🔍 Attempting to load private key from app bundle...")
        // do {
        //     let privateKey = try loadPrivateKeyFromBundle()
        //     print("✅ Loaded ad network private key from bundle")
        //     return privateKey
        // } catch {
        //     print("⚠️ Failed to load private key from bundle: \(error)")
        // }
        
        // Option 3: For development only - create temporary key
        print("⚠️ WARNING: Using temporary development key. Replace with actual ad network private key!")
        print("💡 In production, store your ad network private key in Keychain or app bundle")
        
        do {
            let tempKey = try createTemporaryDevelopmentKey()
            print("✅ Created temporary development key")
            return tempKey
        } catch {
            print("❌ Failed to create temporary development key: \(error)")
            throw error
        }
    }
    
    /// Load private key from app bundle (if embedded during build)
    @available(iOS 17.4, *)
    private func loadPrivateKeyFromBundle() throws -> SecKey {
        guard let keyPath = Bundle.main.path(forResource: "adnetwork_private_key", ofType: "p8"),
              let keyData = NSData(contentsOfFile: keyPath) else {
            throw NSError(domain: "JWSError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ad network private key file not found in bundle"])
        }
        
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateWithData(keyData as CFData, attributes as CFDictionary, &error) else {
            if let error = error?.takeRetainedValue() {
                throw error
            }
            throw NSError(domain: "JWSError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to create private key from bundle data"])
        }
        
        return privateKey
    }
    
    /// Create temporary development key (only for testing)
    @available(iOS 17.4, *)
    private func createTemporaryDevelopmentKey() throws -> SecKey {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            if let error = error?.takeRetainedValue() {
                throw error
            }
            throw NSError(domain: "JWSError", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to create temporary development key"])
        }
        
        return privateKey
    }
    
    /// ES256 signing method conforming to RFC 7515 Section 5.1
    /// Signs: ASCII(BASE64URL(UTF8(JWS Protected Header)) || '.' || BASE64URL(JWS Payload))
    /// Uses the private key from your ad network registration
    @available(iOS 17.4, *)
    private func signWithES256(signingInputData: Data, privateKey: SecKey) throws -> Data {
        // Ensure we're signing the ASCII representation as specified in RFC 7515
        // Input should be: ASCII(BASE64URL(UTF8(JWS Protected Header)) || '.' || BASE64URL(JWS Payload))
        
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(
            privateKey,
            .ecdsaSignatureMessageX962SHA256,  // ES256 algorithm
            signingInputData as CFData,
            &error
        ) else {
            if let error = error?.takeRetainedValue() {
                throw error
            }
            throw NSError(domain: "JWSError", code: -1, userInfo: [NSLocalizedDescriptionKey: "ES256 signing failed with ad network private key"])
        }
        
        print("✅ Successfully signed JWS with ES256 using ad network private key")
        return signature as Data
    }
    
    /// Store ad network private key during registration process
    /// Call this method when you receive the private key from your ad network
    @available(iOS 17.4, *)
    func storeAdNetworkPrivateKey(_ privateKeyData: Data) throws {
        let keyTag = "com.pageone.adnetwork.registration.privatekey".data(using: .utf8)!
        
        // First, try to create SecKey from the provided data
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateWithData(privateKeyData as CFData, attributes as CFDictionary, &error) else {
            if let error = error?.takeRetainedValue() {
                throw error
            }
            throw NSError(domain: "JWSError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid private key data from ad network"])
        }
        
        // Store in Keychain
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecValueRef as String: privateKey
        ]
        
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        
        if status != errSecSuccess {
            throw NSError(domain: "JWSError", code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Failed to store ad network private key in Keychain"])
        }
        
        print("✅ Ad network private key stored successfully in Keychain")
    }
}
