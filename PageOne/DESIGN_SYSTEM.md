# PageOne Design System

## Overview

The PageOne design system embraces **warm**, **flat**, and **minimalistic** design principles to create a welcoming and distraction-free writing environment. Our design language prioritizes readability, simplicity, and warmth.

## Design Principles

### 🌅 Warmth

-   **Warm Color Palette**: Earth tones, muted oranges, soft browns, and warm grays
-   **Inviting Feel**: Colors that create a cozy, welcoming atmosphere
-   **Human-Centered**: Tones that feel natural and comfortable for extended writing sessions

### 📏 Flat Design

-   **No Gradients**: Clean, solid colors without unnecessary visual complexity
-   **Minimal Shadows**: Subtle elevation using minimal shadows and borders
-   **Clean Edges**: Simple shapes and clear boundaries
-   **Visual Hierarchy**: Achieved through color, typography, and spacing rather than effects

### 🎯 Minimalism

-   **Less is More**: Only essential visual elements
-   **Generous Whitespace**: Breathing room for content and visual clarity
-   **Simplified Typography**: Clean, readable fonts with clear hierarchy
-   **Focused Interactions**: Clear, purposeful UI elements

## Color Palette

### Primary Colors

-   **Warm Orange** (`#F0A678`): Primary accent, buttons, selections
-   **Soft Terracotta** (`#E19672`): Hover states, secondary accents
-   **Light Cream** (`#FAF5ED`): Primary background
-   **Warm Gray** (`#8C857A`): Secondary text, icons
-   **Deep Brown** (`#544A40`): Primary text, headers

### Background Colors

-   **Primary Background**: Light cream for main surfaces
-   **Secondary Background** (`#F5F0E6`): Subtle contrast areas
-   **Surface Background**: Pure white for cards and elevated content

### Semantic Colors

-   **Success**: Muted green (`#C0D1A6`)
-   **Warning**: Soft amber (`#F5D6A6`)
-   **Error**: Gentle coral (`#E3A394`)

## Typography

### Hierarchy

-   **Large Title**: 32pt, Light weight - For major headings
-   **Title 1**: 26pt, Light weight - Page titles
-   **Title 2**: 20pt, Regular weight - Section headers
-   **Title 3**: 18pt, Medium weight - Subsection headers
-   **Body**: 16pt, Regular weight - Main content
-   **Subheadline**: 14pt, Regular weight - Supporting text
-   **Caption**: 11pt, Regular weight - Minor details

### Principles

-   **Readability First**: Comfortable reading experience
-   **Consistent Weights**: Limited to Light, Regular, and Medium
-   **Generous Line Heights**: Improved readability
-   **Clear Hierarchy**: Size and weight create visual structure

## Spacing System

### Scale

-   **XXS**: 2pt - Micro adjustments
-   **XS**: 4pt - Fine spacing
-   **SM**: 8pt - Small gaps
-   **MD**: 12pt - Default spacing
-   **LG**: 16pt - Comfortable separation
-   **XL**: 20pt - Generous spacing
-   **XXL**: 24pt - Section separation
-   **XXXL**: 32pt - Major layout gaps
-   **XXXXL**: 48pt - Large separation

## Components

### Buttons

#### Primary Button

```swift
DSButton("Create Note", icon: "plus") {
    // Action
}
```

-   Warm orange background
-   White text
-   Medium corner radius
-   Subtle press animation

#### Secondary Button

```swift
DSButton("Cancel", style: .secondary) {
    // Action
}
```

-   Secondary background with border
-   Primary text color
-   Same dimensions as primary

#### Floating Action Button

```swift
DSFloatingActionButton(icon: "plus", accessibilityLabel: "Add") {
    // Action
}
```

-   Circular design
-   Warm orange background
-   Minimal shadow for elevation

### Cards & Surfaces

#### Flat Card

```swift
content
    .flatCard()
```

-   White background
-   Subtle border
-   Medium corner radius
-   No heavy shadows

#### Background Modifiers

```swift
content
    .primaryBackground() // Light cream
    .secondaryBackground() // Slightly darker cream
    .surfaceBackground() // Pure white
```

### Text Styling

#### Color Modifiers

```swift
Text("Primary text")
    .primaryText() // Deep brown

Text("Secondary text")
    .secondaryText() // Warm gray

Text("Tertiary text")
    .tertiaryText() // Light warm gray
```

## Usage Guidelines

### Do's ✅

-   Use the defined color palette consistently
-   Maintain generous spacing between elements
-   Apply typography hierarchy appropriately
-   Keep visual effects minimal and purposeful
-   Use warm colors to create inviting experiences

### Don'ts ❌

-   Don't add unnecessary gradients or heavy shadows
-   Don't use colors outside the defined palette
-   Don't overcrowd interfaces with excessive elements
-   Don't use bold or heavy font weights excessively
-   Don't ignore the spacing system

## Implementation

### SwiftUI

All design tokens are available through the `DesignSystem` struct:

```swift
// Colors
DesignSystem.Colors.warmOrange
DesignSystem.Colors.primaryBackground

// Typography
DesignSystem.Typography.title2
DesignSystem.Typography.body

// Spacing
DesignSystem.Spacing.lg
DesignSystem.Spacing.xxl
```

### UIKit

UIKit equivalents are provided with `ui` prefix:

```swift
// Colors
DesignSystem.Colors.uiWarmOrange
DesignSystem.Colors.uiPrimaryBackground

// Typography
DesignSystem.Typography.uiTitle2
DesignSystem.Typography.uiBody
```

## Preview

To see all components in action, check out `DesignSystemPreview.swift` which showcases:

-   Color palette swatches
-   Typography examples
-   Button variations
-   Card and surface styles

---

_This design system supports PageOne's mission to provide a warm, welcoming, and distraction-free writing environment._
