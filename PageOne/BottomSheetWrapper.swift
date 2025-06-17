import SwiftUI
import UIKit

// MARK: - SwiftUI Wrapper for UIKit Bottom Sheet
struct BottomSheetWrapper: UIViewControllerRepresentable {
    let notes: [NoteEntity]
    let selectedNote: NoteEntity?
    let onNoteSelected: (NoteEntity) -> Void
    let onDismiss: () -> Void
    let onNewNote: () -> Void
    let onNoteDeleted: (NoteEntity) -> Void
    let presentationID: UUID // Unique ID for each presentation request
    
    func makeUIViewController(context: Context) -> EmptyViewController {
        return EmptyViewController()
    }
    
    func updateUIViewController(_ uiViewController: EmptyViewController, context: Context) {
        // Only present if this is a new presentation request
        context.coordinator.presentIfNeeded(
            presentationID: presentationID,
            notes: notes,
            selectedNote: selectedNote
        )
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, BottomSheetDelegate {
        let parent: BottomSheetWrapper
        private var lastPresentationID: UUID?
        private var currentBottomSheet: BottomSheetViewController?
        
        init(_ parent: BottomSheetWrapper) {
            self.parent = parent
        }
        
        func presentIfNeeded(presentationID: UUID, notes: [NoteEntity], selectedNote: NoteEntity?) {
            // Only present if this is a new request and we don't have a sheet already
            guard lastPresentationID != presentationID && currentBottomSheet == nil else {
                return
            }
            
            print("New presentation request: \(presentationID)")
            lastPresentationID = presentationID
            
            // Find the root view controller
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                print("Could not find root view controller")
                return
            }
            
            // Find the topmost view controller
            var topViewController = rootViewController
            while let presentedViewController = topViewController.presentedViewController {
                topViewController = presentedViewController
            }
            
            // Check if there's already a bottom sheet
            if topViewController is BottomSheetViewController {
                print("Bottom sheet already presented")
                return
            }
            
            print("Presenting bottom sheet with \(notes.count) notes")
            
            // Create and configure bottom sheet
            let bottomSheet = BottomSheetViewController()
            bottomSheet.delegate = self
            bottomSheet.configure(with: notes, selectedNote: selectedNote)
            
            // Store reference and set up dismissal tracking
            currentBottomSheet = bottomSheet
            bottomSheet.presentationController?.delegate = self
            
            // Present the bottom sheet
            topViewController.present(bottomSheet, animated: true) {
                print("Bottom sheet presentation completed")
            }
        }
        
        // MARK: - BottomSheetDelegate
        func bottomSheetDidSelectNote(_ note: NoteEntity) {
            print("Note selected, dismissing sheet")
            cleanup()
            parent.onNoteSelected(note)
        }
        
        func bottomSheetDidRequestDismissal() {
            print("Dismissal requested, dismissing sheet")
            cleanup()
            parent.onDismiss()
        }
        
        func bottomSheetDidRequestNewNote() {
            print("New note requested, dismissing sheet")
            cleanup()
            parent.onNewNote()
        }
        
        func bottomSheetDidDeleteNote(_ note: NoteEntity) {
            print("Note delete requested: \(note.title ?? "No title")")
            parent.onNoteDeleted(note)
        }
        
        private func cleanup() {
            print("Cleaning up coordinator state")
            currentBottomSheet = nil
            // Note: We keep lastPresentationID to prevent re-presentation
        }
    }
}

// MARK: - Presentation Controller Delegate
extension BottomSheetWrapper.Coordinator: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("Sheet dismissed by gesture")
        cleanup()
        parent.onDismiss()
    }
}

// MARK: - Empty View Controller
class EmptyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.isUserInteractionEnabled = false
    }
}

// MARK: - View Modifier for Easy Bottom Sheet Presentation
struct BottomSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    let notes: [NoteEntity]
    let selectedNote: NoteEntity?
    let onNoteSelected: (NoteEntity) -> Void
    let onNewNote: () -> Void
    let onNoteDeleted: (NoteEntity) -> Void
    
    @State private var presentationID = UUID()
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if isPresented {
                        BottomSheetWrapper(
                            notes: notes,
                            selectedNote: selectedNote,
                            onNoteSelected: { note in
                                print("BottomSheetModifier: Note selected")
                                isPresented = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    onNoteSelected(note)
                                }
                            },
                            onDismiss: {
                                print("BottomSheetModifier: Dismissed")
                                isPresented = false
                            },
                            onNewNote: {
                                print("BottomSheetModifier: New note")
                                isPresented = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    onNewNote()
                                }
                            },
                            onNoteDeleted: { note in
                                print("BottomSheetModifier: Note deleted")
                                onNoteDeleted(note)
                            },
                            presentationID: presentationID
                        )
                        .allowsHitTesting(false)
                    }
                }
            )
            .onChange(of: isPresented) { newValue in
                if newValue {
                    // Generate new ID for each presentation request
                    presentationID = UUID()
                    print("New presentation ID generated: \(presentationID)")
                }
            }
    }
}

// MARK: - View Extension for Convenient Usage
extension View {
    func bottomSheet(
        isPresented: Binding<Bool>,
        notes: [NoteEntity],
        selectedNote: NoteEntity?,
        onNoteSelected: @escaping (NoteEntity) -> Void,
        onNewNote: @escaping () -> Void,
        onNoteDeleted: @escaping (NoteEntity) -> Void
    ) -> some View {
        self.modifier(
            BottomSheetModifier(
                isPresented: isPresented,
                notes: notes,
                selectedNote: selectedNote,
                onNoteSelected: onNoteSelected,
                onNewNote: onNewNote,
                onNoteDeleted: onNoteDeleted
            )
        )
    }
}

// MARK: - Alternative Direct Presentation Helper (for pure UIKit usage)
struct UIKitBottomSheetPresenter {
    static func present(
        from viewController: UIViewController,
        with notes: [NoteEntity],
        selectedNote: NoteEntity?,
        delegate: BottomSheetDelegate?
    ) {
        // Check if a sheet is already presented
        guard viewController.presentedViewController == nil else {
            print("Warning: Bottom sheet already presented")
            return
        }
        
        let bottomSheet = BottomSheetViewController()
        bottomSheet.delegate = delegate
        bottomSheet.configure(with: notes, selectedNote: selectedNote)
        
        viewController.present(bottomSheet, animated: true)
    }
}

// MARK: - Usage Documentation
/*
 
 ## How This ID-Based Implementation Works:
 
 1. **Presentation ID System**: Each presentation request gets a unique UUID
 2. **Single Presentation Rule**: Each ID can only trigger one presentation
 3. **State Isolation**: Coordinator tracks last presented ID to prevent duplicates
 4. **Clean Separation**: SwiftUI state changes generate new IDs
 
 ## Key Features:
 
 - ✅ **Prevents Auto-Reopening**: Each presentation ID used only once
 - ✅ **Eliminates Race Conditions**: No timing-dependent state synchronization
 - ✅ **Simple Logic**: Present once per ID, period
 - ✅ **Debug Logging**: Track presentation requests and IDs
 - ✅ **Memory Safe**: Proper cleanup without complex state management
 
 ## How It Prevents Double Presentation:
 
 1. User clicks button → `isPresented = true` → New UUID generated
 2. Sheet presents with that UUID → `lastPresentationID` stored
 3. If `updateUIViewController` called again → Same UUID → Ignored
 4. User dismisses → `isPresented = false` 
 5. User clicks again → `isPresented = true` → **New UUID** → Can present again
 
 */ 