import SwiftUI

// MARK: - Design System Preview
struct DesignSystemPreview: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xxl) {
                    // Colors Section
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                        Text("Color Palette")
                            .font(DesignSystem.Typography.title2)
                            .primaryText()
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: DesignSystem.Spacing.md) {
                            ColorSwatch(color: DesignSystem.Colors.warmOrange, name: "Warm Orange")
                            ColorSwatch(color: DesignSystem.Colors.softTerracotta, name: "Soft Terracotta")
                            ColorSwatch(color: DesignSystem.Colors.lightCream, name: "Light Cream")
                            ColorSwatch(color: DesignSystem.Colors.warmGray, name: "Warm Gray")
                            ColorSwatch(color: DesignSystem.Colors.deepBrown, name: "Deep Brown")
                            ColorSwatch(color: DesignSystem.Colors.secondaryBackground, name: "Secondary BG")
                        }
                    }
                    
                    // Typography Section
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                        Text("Typography")
                            .font(DesignSystem.Typography.title2)
                            .primaryText()
                        
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text("Large Title - Light & Elegant")
                                .font(DesignSystem.Typography.largeTitle)
                                .primaryText()
                            
                            Text("Title 1 - Clean Headers")
                                .font(DesignSystem.Typography.title1)
                                .primaryText()
                            
                            Text("Title 2 - Section Headers")
                                .font(DesignSystem.Typography.title2)
                                .primaryText()
                            
                            Text("Body - Perfect for reading")
                                .font(DesignSystem.Typography.body)
                                .primaryText()
                            
                            Text("Subheadline - Supporting text")
                                .font(DesignSystem.Typography.subheadline)
                                .secondaryText()
                            
                            Text("Caption - Small details")
                                .font(DesignSystem.Typography.caption)
                                .tertiaryText()
                        }
                    }
                    
                    // Buttons Section
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                        Text("Buttons")
                            .font(DesignSystem.Typography.title2)
                            .primaryText()
                        
                        VStack(spacing: DesignSystem.Spacing.md) {
                            DSButton("Primary Button", icon: "star.fill") {
                                print("Primary button tapped")
                            }
                            
                            DSButton("Secondary Button", icon: "heart", style: .secondary) {
                                print("Secondary button tapped")
                            }
                            
                            HStack {
                                DSFloatingActionButton(icon: "plus", accessibilityLabel: "Add") {
                                    print("Add button tapped")
                                }
                                
                                DSFloatingActionButton(icon: "list.bullet", accessibilityLabel: "List") {
                                    print("List button tapped")
                                }
                            }
                        }
                    }
                    
                    // Cards Section
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                        Text("Cards & Surfaces")
                            .font(DesignSystem.Typography.title2)
                            .primaryText()
                        
                        VStack(spacing: DesignSystem.Spacing.lg) {
                            // Flat card example
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                                HStack {
                                    Image(systemName: "doc.text")
                                        .foregroundStyle(DesignSystem.Colors.accent)
                                    
                                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                        Text("Note Title")
                                            .font(DesignSystem.Typography.bodyMedium)
                                            .primaryText()
                                        
                                        Text("This is a preview of the note content showing how our flat card design looks...")
                                            .font(DesignSystem.Typography.subheadline)
                                            .secondaryText()
                                            .lineLimit(2)
                                    }
                                    
                                    Spacer()
                                }
                                
                                Text("2 hours ago")
                                    .font(DesignSystem.Typography.caption)
                                    .tertiaryText()
                            }
                            .padding(DesignSystem.Spacing.lg)
                            .flatCard()
                            
                            // Surface background example
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                Text("Surface Background")
                                    .font(DesignSystem.Typography.title3)
                                    .primaryText()
                                
                                Text("This demonstrates our clean, minimal surface styling with subtle borders and no heavy shadows.")
                                    .font(DesignSystem.Typography.body)
                                    .secondaryText()
                            }
                            .padding(DesignSystem.Spacing.lg)
                            .surfaceBackground()
                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(DesignSystem.Spacing.xl)
            }
            .primaryBackground()
            .navigationTitle("Design System")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ColorSwatch: View {
    let color: Color
    let name: String
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                .fill(color)
                .frame(height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                        .stroke(DesignSystem.Colors.border, lineWidth: 1)
                )
            
            Text(name)
                .font(DesignSystem.Typography.caption)
                .secondaryText()
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Preview
struct DesignSystemPreview_Previews: PreviewProvider {
    static var previews: some View {
        DesignSystemPreview()
    }
} 