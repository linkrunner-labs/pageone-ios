import SwiftUI
import UIKit

// MARK: - Design System
struct DesignSystem {
    
    // MARK: - Color Palette (Warm & Minimalistic)
    struct Colors {
        // Primary warm colors
        static let warmOrange = Color(red: 0.94, green: 0.65, blue: 0.47) // #F0A678
        static let softTerracotta = Color(red: 0.88, green: 0.59, blue: 0.45) // #E19672
        static let lightCream = Color(red: 0.98, green: 0.96, blue: 0.93) // #FAF5ED
        static let warmGray = Color(red: 0.55, green: 0.52, blue: 0.48) // #8C857A
        static let deepBrown = Color(red: 0.33, green: 0.29, blue: 0.25) // #544A40
        
        // Background colors
        static let primaryBackground = lightCream
        static let secondaryBackground = Color(red: 0.96, green: 0.94, blue: 0.90) // #F5F0E6
        static let surfaceBackground = Color.white
        
        // Text colors
        static let primaryText = deepBrown
        static let secondaryText = warmGray
        static let tertiaryText = Color(red: 0.70, green: 0.67, blue: 0.63) // #B3ABA1
        
        // Interactive colors
        static let accent = warmOrange
        static let accentHover = softTerracotta
        static let success = Color(red: 0.75, green: 0.82, blue: 0.65) // #C0D1A6
        static let warning = Color(red: 0.96, green: 0.84, blue: 0.65) // #F5D6A6
        static let error = Color(red: 0.89, green: 0.64, blue: 0.58) // #E3A394
        
        // Neutral colors
        static let border = Color(red: 0.90, green: 0.87, blue: 0.83) // #E6DED4
        static let separator = Color(red: 0.92, green: 0.90, blue: 0.87) // #EBE6DE
        static let shadow = Color.black.opacity(0.05)
        
        // UIKit equivalents
        static let uiWarmOrange = UIColor(red: 0.94, green: 0.65, blue: 0.47, alpha: 1.0)
        static let uiSoftTerracotta = UIColor(red: 0.88, green: 0.59, blue: 0.45, alpha: 1.0)
        static let uiLightCream = UIColor(red: 0.98, green: 0.96, blue: 0.93, alpha: 1.0)
        static let uiWarmGray = UIColor(red: 0.55, green: 0.52, blue: 0.48, alpha: 1.0)
        static let uiDeepBrown = UIColor(red: 0.33, green: 0.29, blue: 0.25, alpha: 1.0)
        static let uiPrimaryBackground = uiLightCream
        static let uiSecondaryBackground = UIColor(red: 0.96, green: 0.94, blue: 0.90, alpha: 1.0)
        static let uiBorder = UIColor(red: 0.90, green: 0.87, blue: 0.83, alpha: 1.0)
        static let uiSeparator = UIColor(red: 0.92, green: 0.90, blue: 0.87, alpha: 1.0)
    }
    
    // MARK: - Typography
    struct Typography {
        // Titles
        static let largeTitle = Font.system(size: 32, weight: .light, design: .default)
        static let title1 = Font.system(size: 26, weight: .light, design: .default)
        static let title2 = Font.system(size: 20, weight: .regular, design: .default)
        static let title3 = Font.system(size: 18, weight: .medium, design: .default)
        
        // Body text
        static let body = Font.system(size: 16, weight: .regular, design: .default)
        static let bodyMedium = Font.system(size: 16, weight: .medium, design: .default)
        static let callout = Font.system(size: 15, weight: .regular, design: .default)
        static let subheadline = Font.system(size: 14, weight: .regular, design: .default)
        
        // Small text
        static let footnote = Font.system(size: 12, weight: .regular, design: .default)
        static let caption = Font.system(size: 11, weight: .regular, design: .default)
        static let caption2 = Font.system(size: 10, weight: .regular, design: .default)
        
        // UIKit equivalents
        static let uiLargeTitle = UIFont.systemFont(ofSize: 32, weight: .light)
        static let uiTitle1 = UIFont.systemFont(ofSize: 26, weight: .light)
        static let uiTitle2 = UIFont.systemFont(ofSize: 20, weight: .regular)
        static let uiTitle3 = UIFont.systemFont(ofSize: 18, weight: .medium)
        static let uiBody = UIFont.systemFont(ofSize: 16, weight: .regular)
        static let uiBodyMedium = UIFont.systemFont(ofSize: 16, weight: .medium)
        static let uiCallout = UIFont.systemFont(ofSize: 15, weight: .regular)
        static let uiSubheadline = UIFont.systemFont(ofSize: 14, weight: .regular)
        static let uiFootnote = UIFont.systemFont(ofSize: 12, weight: .regular)
        static let uiCaption = UIFont.systemFont(ofSize: 11, weight: .regular)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
        static let xxxxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct Radius {
        static let none: CGFloat = 0
        static let xs: CGFloat = 4
        static let sm: CGFloat = 6
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
        static let xxl: CGFloat = 20
        static let circular: CGFloat = 1000
    }
    
    // MARK: - Shadows (Minimal)
    struct Shadow {
        static let none = Shadow(color: .clear, radius: 0, x: 0, y: 0)
        static let subtle = Shadow(color: Colors.shadow, radius: 2, x: 0, y: 1)
        static let soft = Shadow(color: Colors.shadow, radius: 4, x: 0, y: 2)
        static let medium = Shadow(color: Colors.shadow, radius: 8, x: 0, y: 4)
        
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - Design System View Modifiers
extension View {
    // Background modifiers
    func primaryBackground() -> some View {
        self.background(DesignSystem.Colors.primaryBackground)
    }
    
    func secondaryBackground() -> some View {
        self.background(DesignSystem.Colors.secondaryBackground)
    }
    
    func surfaceBackground() -> some View {
        self.background(DesignSystem.Colors.surfaceBackground)
    }
    
    // Text color modifiers
    func primaryText() -> some View {
        self.foregroundStyle(DesignSystem.Colors.primaryText)
    }
    
    func secondaryText() -> some View {
        self.foregroundStyle(DesignSystem.Colors.secondaryText)
    }
    
    func tertiaryText() -> some View {
        self.foregroundStyle(DesignSystem.Colors.tertiaryText)
    }
    
    // Card style (flat design)
    func flatCard() -> some View {
        self
            .surfaceBackground()
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
    }
    
    // Button styles
    func primaryButton() -> some View {
        self
            .foregroundStyle(.white)
            .background(DesignSystem.Colors.accent)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
    }
    
    func secondaryButton() -> some View {
        self
            .primaryText()
            .background(DesignSystem.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
    }
    
    // Subtle shadow for minimal elevation
    func subtleShadow() -> some View {
        self.shadow(
            color: DesignSystem.Shadow.subtle.color,
            radius: DesignSystem.Shadow.subtle.radius,
            x: DesignSystem.Shadow.subtle.x,
            y: DesignSystem.Shadow.subtle.y
        )
    }
}

// MARK: - Design System Components
struct DSButton: View {
    enum Style {
        case primary
        case secondary
        case floating
    }
    
    let title: String
    let icon: String?
    let style: Style
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(_ title: String, icon: String? = nil, style: Style = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                }
                
                if !title.isEmpty {
                    Text(title)
                        .font(DesignSystem.Typography.callout)
                        .fontWeight(.medium)
                }
            }
            .padding(.horizontal, style == .floating ? DesignSystem.Spacing.lg : DesignSystem.Spacing.lg)
            .padding(.vertical, style == .floating ? DesignSystem.Spacing.lg : DesignSystem.Spacing.md)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onPressGesture(
            onPress: { isPressed = true },
            onRelease: { isPressed = false }
        )
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .modifier(ButtonStyleModifier(style: style))
    }
}

struct ButtonStyleModifier: ViewModifier {
    let style: DSButton.Style
    
    func body(content: Content) -> some View {
        switch style {
        case .primary:
            content.primaryButton()
        case .secondary:
            content.secondaryButton()
        case .floating:
            content
                .foregroundStyle(.white)
                .background(
                    Circle()
                        .fill(DesignSystem.Colors.accent)
                )
                .subtleShadow()
        }
    }
}

struct DSFloatingActionButton: View {
    let icon: String
    let accessibilityLabel: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(
                    Circle()
                        .fill(DesignSystem.Colors.accent)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .subtleShadow()
        }
        .buttonStyle(PlainButtonStyle())
        .onPressGesture(
            onPress: { isPressed = true },
            onRelease: { isPressed = false }
        )
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Custom press gesture modifier (if not already defined)
extension View {
    func onPressGesture(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onRelease() }
        )
    }
} 