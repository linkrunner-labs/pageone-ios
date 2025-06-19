import SwiftUI
import CoreData
import Combine

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \NoteEntity.createdAt, ascending: false)],
        animation: .default)
    private var notes: FetchedResults<NoteEntity>
    
    @State private var selectedNote: NoteEntity?
    @State private var bottomSheetDelegate: ContentViewBottomSheetDelegate?
    
    // Computed properties for responsive design
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    private var floatingButtonBottomPadding: CGFloat {
        isLandscape ? DesignSystem.Spacing.xl / 2 : DesignSystem.Spacing.xxxxl / 2
    }
    
    var body: some View {
        ZStack {
            // Warm background
            DesignSystem.Colors.primaryBackground
                .ignoresSafeArea()
            
            // Main content area
            Group {
                if let note = selectedNote {
                    NoteEditView(note: note)
                        .id(note.id)
                } else {
                    EmptyStateView()
                        .onAppear {
                            if notes.isEmpty {
                                createNewNote()
                            }
                        }
                }
            }
            
            // Floating Action Buttons
            VStack {
                Spacer()
                HStack {
                    DSFloatingActionButton(
                        icon: "list.bullet",
                        accessibilityLabel: "Show notes list",
                        action: presentNotesSheet
                    )
                    
                    Spacer()
                    
                    DSFloatingActionButton(
                        icon: "plus",
                        accessibilityLabel: "Create new note",
                        action: createNewNote
                    )
                }
                .padding(.bottom, floatingButtonBottomPadding)
                .padding(.horizontal, DesignSystem.Spacing.xl)
            }
        }
        .onAppear {
            // Auto-select first note or create one
            if let firstNote = notes.first {
                selectedNote = firstNote
                print("Auto-selected first note: \(firstNote.title ?? "No title")")
            } else {
                createNewNote()
            }
        }
    }
    
    private func createNewNote() {
        print("Create new note button tapped!")
        
        let newNote = NoteEntity(context: viewContext)
        newNote.id = UUID()
        newNote.createdAt = Date()
        newNote.updatedAt = Date()
        newNote.body = ""
        
        // Generate title using specified format
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH-mm"
        newNote.title = "Note \(formatter.string(from: Date()))"
        
        do {
            try viewContext.save()
            print("New note saved successfully: \(newNote.title ?? "No title")")
            
            // Immediately set the new note as selected with animation
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedNote = newNote
                print("Selected note set to: \(selectedNote?.title ?? "None")")
            }
            
        } catch {
            print("Error creating note: \(error)")
        }
    }
    
    private func presentNotesSheet() {
        print("Notes sheet button tapped!")
        
        // Dismiss keyboard when opening menu
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        // Add haptic feedback for opening
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
        
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
        
        // Check if there's already a bottom sheet presented
        if topViewController is BottomSheetViewController {
            print("Bottom sheet already presented")
            return
        }
        
        print("Presenting bottom sheet with \(notes.count) notes")
        
        // Create and configure bottom sheet
        let bottomSheet = BottomSheetViewController()
        let delegate = ContentViewBottomSheetDelegate(
            selectedNote: Binding(
                get: { selectedNote },
                set: { newValue in
                    print("Setting selectedNote to: \(newValue?.title ?? "nil")")
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedNote = newValue
                    }
                }
            ),
            viewContext: viewContext,
            notes: notes
        )
        bottomSheetDelegate = delegate  // Store reference to prevent deallocation
        bottomSheet.delegate = delegate
        bottomSheet.configure(with: Array(notes), selectedNote: selectedNote)
        
        // Present with smooth animation
        topViewController.present(bottomSheet, animated: true) {
            print("Bottom sheet presentation completed")
        }
    }
    
    private func deleteNote(_ note: NoteEntity) {
        print("Deleting note: \(note.title ?? "No title")")
        
        // If the deleted note is currently selected, select another note or clear selection
        if selectedNote == note {
            // Find another note to select (prefer the next one, or the previous one, or nil)
            if let currentIndex = notes.firstIndex(of: note) {
                if currentIndex + 1 < notes.count {
                    // Select the next note
                    selectedNote = notes[currentIndex + 1]
                } else if currentIndex > 0 {
                    // Select the previous note
                    selectedNote = notes[currentIndex - 1]
                } else {
                    // No other notes available
                    selectedNote = nil
                }
            } else {
                selectedNote = nil
            }
        }
        
        // Delete from Core Data
        viewContext.delete(note)
        
        do {
            try viewContext.save()
            print("Note deleted successfully from Core Data")
            
            // If no notes left, create a new one
            if notes.isEmpty && selectedNote == nil {
                createNewNote()
            }
            
        } catch {
            print("Error deleting note: \(error)")
        }
    }
}

// MARK: - Bottom Sheet Delegate Wrapper
private class ContentViewBottomSheetDelegate: NSObject, BottomSheetDelegate {
    private let selectedNote: Binding<NoteEntity?>
    private let viewContext: NSManagedObjectContext
    private let notes: FetchedResults<NoteEntity>
    
    init(
        selectedNote: Binding<NoteEntity?>,
        viewContext: NSManagedObjectContext,
        notes: FetchedResults<NoteEntity>
    ) {
        self.selectedNote = selectedNote
        self.viewContext = viewContext
        self.notes = notes
    }
    
    func bottomSheetDidSelectNote(_ note: NoteEntity) {
        print("Bottom sheet note selected: \(note.title ?? "No title") with ID: \(note.id?.uuidString ?? "no ID")")
        print("Current selectedNote: \(selectedNote.wrappedValue?.title ?? "nil") with ID: \(selectedNote.wrappedValue?.id?.uuidString ?? "no ID")")
        selectedNote.wrappedValue = note
        print("After setting, selectedNote: \(selectedNote.wrappedValue?.title ?? "nil") with ID: \(selectedNote.wrappedValue?.id?.uuidString ?? "no ID")")
    }
    
    func bottomSheetDidRequestDismissal() {
        print("Bottom sheet dismissed")
        // Nothing needed - UIKit handles dismissal automatically
    }
    
    func bottomSheetDidRequestNewNote() {
        print("Bottom sheet new note requested")
        createNewNote()
    }
    
    func bottomSheetDidDeleteNote(_ note: NoteEntity) {
        print("Bottom sheet note delete requested: \(note.title ?? "No title")")
        deleteNote(note)
    }
    
    private func createNewNote() {
        let newNote = NoteEntity(context: viewContext)
        newNote.id = UUID()
        newNote.createdAt = Date()
        newNote.updatedAt = Date()
        newNote.body = ""
        
        // Generate title using specified format
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH-mm"
        newNote.title = "Note \(formatter.string(from: Date()))"
        
        do {
            try viewContext.save()
            print("New note saved successfully: \(newNote.title ?? "No title")")
            
            // Set the new note as selected
            selectedNote.wrappedValue = newNote
            print("Selected note set to: \(newNote.title ?? "None")")
            
        } catch {
            print("Error creating note: \(error)")
        }
    }
    
    private func deleteNote(_ note: NoteEntity) {
        // If the deleted note is currently selected, select another note or clear selection
        if selectedNote.wrappedValue == note {
            // Find another note to select (prefer the next one, or the previous one, or nil)
            if let currentIndex = notes.firstIndex(of: note) {
                if currentIndex + 1 < notes.count {
                    // Select the next note
                    selectedNote.wrappedValue = notes[currentIndex + 1]
                } else if currentIndex > 0 {
                    // Select the previous note
                    selectedNote.wrappedValue = notes[currentIndex - 1]
                } else {
                    // No other notes available
                    selectedNote.wrappedValue = nil
                }
            } else {
                selectedNote.wrappedValue = nil
            }
        }
        
        // Delete from Core Data
        viewContext.delete(note)
        
        do {
            try viewContext.save()
            print("Note deleted successfully from Core Data")
            
            // If no notes left, create a new one
            if notes.isEmpty && selectedNote.wrappedValue == nil {
                createNewNote()
            }
            
        } catch {
            print("Error deleting note: \(error)")
        }
    }
}

struct NoteEditView: View {
    @ObservedObject var note: NoteEntity
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var textContent: String = ""
    @State private var saveWorkItem: DispatchWorkItem?
    @FocusState private var isTextFieldFocused: Bool
    
    // Computed properties for responsive design
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    private var bottomContentMargin: CGFloat {
        // Calculate the total height needed for floating buttons:
        // Button height (52) + bottom padding + some extra buffer
        let buttonHeight: CGFloat = 52
        let buttonBottomPadding = isLandscape ? DesignSystem.Spacing.xl / 2 : DesignSystem.Spacing.xxxxl / 2
        let extraBuffer: CGFloat = DesignSystem.Spacing.md // Extra space for comfort
        
        return buttonHeight + buttonBottomPadding + extraBuffer
    }
    
    var body: some View {
        TextEditor(text: $textContent)
            .font(DesignSystem.Typography.body)
            .primaryText()
            .focused($isTextFieldFocused)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.top, DesignSystem.Spacing.lg)
            .contentMargins(.bottom, bottomContentMargin)
            .background(DesignSystem.Colors.primaryBackground)
            .scrollContentBackground(.hidden) // Hide the default white background
            .mask(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .black, location: 0),
                        .init(color: .black, location: 0.95),
                        .init(color: .clear, location: 1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .onChange(of: textContent) { newValue in
                debouncedSave(newValue)
            }
            .onAppear {
                textContent = note.body ?? ""
                print("NoteEditView appeared with note: \(note.title ?? "No title") with ID: \(note.id?.uuidString ?? "no ID")")
                print("Setting textContent to: \(textContent)")
                // Auto-focus keyboard on launch
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isTextFieldFocused = true
                }
            }
            .navigationBarHidden(true)
    }
    
    private func debouncedSave(_ newText: String) {
        // Cancel previous save operation
        saveWorkItem?.cancel()
        
        // Create new save work item with 500ms delay
        let workItem = DispatchWorkItem {
            note.body = newText
            note.updatedAt = Date()
            
            do {
                try viewContext.save()
                print("Note auto-saved: \(note.title ?? "No title")")
            } catch {
                print("Error saving note: \(error)")
            }
        }
        
        saveWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
}

struct EmptyStateView: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    var body: some View {
        Group {
            if isLandscape {
                // Landscape layout - more compact, horizontal arrangement
                HStack(spacing: DesignSystem.Spacing.xxxxl) {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 48, weight: .ultraLight))
                            .foregroundStyle(DesignSystem.Colors.tertiaryText)
                        
                        VStack(spacing: DesignSystem.Spacing.xs) {
                            Text("Welcome to PageOne")
                                .font(DesignSystem.Typography.title3)
                                .fontWeight(.medium)
                                .primaryText()
                            
                            Text("Start writing your thoughts")
                                .font(DesignSystem.Typography.subheadline)
                                .secondaryText()
                        }
                    }
                    
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Image(systemName: "plus.circle.fill")
                                .font(DesignSystem.Typography.subheadline)
                                .foregroundStyle(DesignSystem.Colors.accent)
                            
                            Text("Tap + to create your first note")
                                .font(DesignSystem.Typography.caption)
                                .secondaryText()
                        }
                        
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Image(systemName: "list.bullet")
                                .font(DesignSystem.Typography.subheadline)
                                .foregroundStyle(DesignSystem.Colors.accent)
                            
                            Text("Use list to browse notes")
                                .font(DesignSystem.Typography.caption)
                                .secondaryText()
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xxxl)
            } else {
                // Portrait layout - vertical arrangement
                VStack(spacing: DesignSystem.Spacing.xxl) {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 64, weight: .ultraLight))
                            .foregroundStyle(DesignSystem.Colors.tertiaryText)
                        
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            Text("Welcome to PageOne")
                                .font(DesignSystem.Typography.title2)
                                .fontWeight(.medium)
                                .primaryText()
                            
                            Text("Start writing your thoughts and ideas")
                                .font(DesignSystem.Typography.body)
                                .secondaryText()
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    VStack(spacing: DesignSystem.Spacing.md) {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Image(systemName: "plus.circle.fill")
                                .font(DesignSystem.Typography.callout)
                                .foregroundStyle(DesignSystem.Colors.accent)
                            
                            Text("Tap the + button to create your first note")
                                .font(DesignSystem.Typography.subheadline)
                                .secondaryText()
                        }
                        
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Image(systemName: "list.bullet")
                                .font(DesignSystem.Typography.callout)
                                .foregroundStyle(DesignSystem.Colors.accent)
                            
                            Text("Use the list button to browse all your notes")
                                .font(DesignSystem.Typography.subheadline)
                                .secondaryText()
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xxxl)
                }
                .padding(.horizontal, DesignSystem.Spacing.xxxxl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
