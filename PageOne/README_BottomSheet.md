# UIKit Bottom Sheet Implementation for SwiftUI

This document provides a comprehensive guide to the UIKit-based bottom sheet implementation using `UISheetPresentationController` for iOS 15+.

## Overview

The bottom sheet implementation provides a native iOS experience with professional animations, gestures, and customization options. It's designed to seamlessly integrate with SwiftUI applications while leveraging the power of UIKit's `UISheetPresentationController`.

## Features

### Core Features

-   ✅ **UISheetPresentationController (iOS 15+)** - Native iOS bottom sheet experience
-   ✅ **Multiple Detent Sizes** - `.medium()` and `.large()` for two-stage expansion
-   ✅ **Visible Drag Indicator** - System grabber for intuitive interaction
-   ✅ **Smooth Animations** - Native spring animations and transitions
-   ✅ **Professional UX** - Proper gesture handling and responsive feedback
-   ✅ **SwiftUI Integration** - Seamless bridge between UIKit and SwiftUI

### Advanced Features

-   ✅ **Haptic Feedback** - Contextual haptic responses for all interactions
-   ✅ **Auto Scroll to Selection** - Automatically scrolls to the selected note
-   ✅ **Context Menus** - Long-press for delete actions
-   ✅ **Empty State Handling** - Beautiful empty state when no notes exist
-   ✅ **Responsive Design** - Adapts to different device orientations
-   ✅ **Memory Management** - Proper cleanup and weak references

### Configuration Options

-   ✅ **Custom Corner Radius** - 16pt rounded corners
-   ✅ **Scroll Behavior Control** - Prevents automatic expansion on scroll
-   ✅ **Edge Attachment** - Landscape support with proper width handling
-   ✅ **Dismissal Options** - Tap outside or drag to dismiss
-   ✅ **Delegate Pattern** - Clean communication back to SwiftUI

## Files Structure

```
PageOne/
├── BottomSheetViewController.swift    # Main UIKit bottom sheet controller
├── NoteTableViewCell.swift            # Custom table view cells
├── BottomSheetWrapper.swift           # SwiftUI integration wrapper
└── ContentView.swift                  # Updated to use UIKit sheet
```

## Implementation Details

### 1. BottomSheetViewController.swift

The core UIViewController that implements the bottom sheet using `UISheetPresentationController`.

**Key Components:**

-   Header with title, close button, and "New Note" button
-   Table view with custom cells for notes
-   Empty state handling
-   Context menu support for note deletion
-   Haptic feedback integration

**Sheet Configuration:**

```swift
sheet.detents = [.medium(), .large()]
sheet.prefersGrabberVisible = true
sheet.prefersScrollingExpandsWhenScrolledToEdge = false
sheet.prefersEdgeAttachedInCompactHeight = true
sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
sheet.preferredCornerRadius = 16
```

### 2. NoteTableViewCell.swift

Custom table view cells with:

-   Professional layout with icon, title, preview, and date
-   Selection state animations
-   Highlight effects on touch
-   Separator line management

### 3. BottomSheetWrapper.swift

SwiftUI integration layer providing:

-   `UIViewControllerRepresentable` wrapper
-   Coordinator for delegate pattern
-   View modifier for easy usage
-   Extension methods for convenience

## Usage Examples

### Basic Usage with View Modifier (Recommended)

```swift
struct MyView: View {
    @State private var showBottomSheet = false
    @State private var selectedNote: NoteEntity?
    @FetchRequest var notes: FetchedResults<NoteEntity>

    var body: some View {
        VStack {
            Button("Show Notes") {
                showBottomSheet = true
            }
        }
        .bottomSheet(
            isPresented: $showBottomSheet,
            notes: Array(notes),
            selectedNote: selectedNote,
            onNoteSelected: { note in
                selectedNote = note
                print("Selected: \(note.title ?? "")")
            },
            onNewNote: {
                createNewNote()
            }
        )
    }
}
```

### Direct UIViewControllerRepresentable Usage

```swift
struct MyView: View {
    @State private var showBottomSheet = false
    let notes: [NoteEntity]

    var body: some View {
        VStack {
            if showBottomSheet {
                BottomSheetWrapper(
                    notes: notes,
                    selectedNote: selectedNote,
                    onNoteSelected: { note in
                        handleNoteSelection(note)
                    },
                    onDismiss: {
                        showBottomSheet = false
                    },
                    onNewNote: {
                        createNewNote()
                    }
                )
            }
        }
    }
}
```

### Pure UIKit Usage

```swift
class MyViewController: UIViewController, BottomSheetDelegate {

    func presentBottomSheet() {
        UIKitBottomSheetPresenter.present(
            from: self,
            with: notes,
            selectedNote: selectedNote,
            delegate: self
        )
    }

    // MARK: - BottomSheetDelegate

    func bottomSheetDidSelectNote(_ note: NoteEntity) {
        // Handle note selection
        self.selectedNote = note
    }

    func bottomSheetDidRequestDismissal() {
        // Handle dismissal
        print("Bottom sheet dismissed")
    }

    func bottomSheetDidRequestNewNote() {
        // Handle new note creation
        createNewNote()
    }
}
```

### Extension Method Usage

```swift
// From any UIViewController
self.presentBottomSheet(
    with: notes,
    selectedNote: currentNote,
    delegate: self
)
```

## Delegate Protocol

```swift
protocol BottomSheetDelegate: AnyObject {
    func bottomSheetDidSelectNote(_ note: NoteEntity)
    func bottomSheetDidRequestDismissal()
    func bottomSheetDidRequestNewNote()
}
```

## Customization Options

### Appearance Customization

```swift
// In BottomSheetViewController
private func configureSheetPresentation() {
    guard let sheet = sheetPresentationController else { return }

    // Customize detents
    sheet.detents = [.medium(), .large(), .custom { _ in 400 }]

    // Customize corner radius
    sheet.preferredCornerRadius = 20

    // Initial detent
    sheet.selectedDetentIdentifier = .medium
}
```

### Cell Customization

```swift
// In NoteTableViewCell
private func updateSelectionState(animated: Bool) {
    let backgroundColor: UIColor = isNoteSelected ? .systemBlue : .clear
    // Customize colors and animations
}
```

## Performance Considerations

1. **Lazy Loading**: Table view cells are reused efficiently
2. **Memory Management**: Weak references prevent retain cycles
3. **Smooth Animations**: Native UIKit animations for best performance
4. **Debounced Updates**: Efficient state synchronization

## Accessibility

-   VoiceOver support for all interactive elements
-   Semantic accessibility labels
-   Proper focus management
-   High contrast support

## Requirements

-   iOS 15.0+
-   Swift 5.5+
-   UIKit framework
-   SwiftUI framework

## Migration from SwiftUI Bottom Sheet

The implementation replaces the previous SwiftUI bottom sheet with these benefits:

1. **Better Performance**: Native UIKit animations and scrolling
2. **More Professional UX**: System-standard behavior and gestures
3. **Better Accessibility**: Built-in UIKit accessibility features
4. **Easier Maintenance**: Standard UIKit patterns and lifecycle

## Troubleshooting

### Common Issues

1. **Sheet not appearing**: Ensure the presenting view controller is in the view hierarchy
2. **Delegate not called**: Check that delegate is properly set and not nil
3. **Animation issues**: Verify iOS 15+ deployment target

### Debug Tips

```swift
// Enable debug logging
print("Bottom sheet presentation: \(sheet.detents)")
print("Selected detent: \(sheet.selectedDetentIdentifier)")
```

## Future Enhancements

-   [ ] Custom detent heights
-   [ ] Pull-to-refresh functionality
-   [ ] Search functionality in the sheet
-   [ ] Batch operations (multi-select)
-   [ ] Custom header configurations
-   [ ] Theming support

## Contributing

When contributing to this implementation:

1. Follow iOS Human Interface Guidelines
2. Maintain accessibility standards
3. Add comprehensive documentation
4. Include unit tests for new features
5. Test on multiple device sizes and orientations

## License

This implementation follows the same license as the main project.
