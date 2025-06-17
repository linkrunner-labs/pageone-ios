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
    @State private var showNotesSheet: Bool = false
    @State private var isToggling: Bool = false // Add state to prevent rapid toggles
    
    // Computed properties for responsive design
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    private var floatingButtonBottomPadding: CGFloat {
        isLandscape ? DesignSystem.Spacing.xl : DesignSystem.Spacing.xxxxl
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
                } else {
                    EmptyStateView()
                        .onAppear {
                            if notes.isEmpty {
                                createNewNote()
                            }
                        }
                }
            }
            
            // UIKit Bottom Sheet Integration
            EmptyView()
            
            // Floating Action Buttons
            VStack {
                Spacer()
                HStack {
                    DSFloatingActionButton(
                        icon: "list.bullet",
                        accessibilityLabel: "Show notes list",
                        action: toggleNotesSheet
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
        .bottomSheet(
            isPresented: $showNotesSheet,
            notes: Array(notes),
            selectedNote: selectedNote,
            onNoteSelected: { note in
                print("Bottom sheet note selected: \(note.title ?? "No title")")
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedNote = note
                }
                isToggling = false
            },
            onNewNote: {
                print("Bottom sheet new note requested")
                createNewNote()
                isToggling = false
            }
        )
        .onChange(of: showNotesSheet) { newValue in
            print("showNotesSheet changed to: \(newValue)")
            if !newValue {
                isToggling = false
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
            
            // Hide bottom sheet after creating note (if currently shown)
            if showNotesSheet {
                showNotesSheet = false
                print("Notes sheet hidden after creating new note")
                isToggling = false
            }
            
        } catch {
            print("Error creating note: \(error)")
        }
    }
    
    private func toggleNotesSheet() {
        print("Toggle notes sheet button tapped!")
        print("Current showNotesSheet: \(showNotesSheet), isToggling: \(isToggling)")
        
        // Prevent rapid toggles
        guard !isToggling else {
            print("Toggle ignored - already in progress")
            return
        }
        
        // Only allow opening if not already shown
        guard !showNotesSheet else {
            print("Notes sheet already shown")
            return
        }
        
        // Set toggling state
        isToggling = true
        
        // Dismiss keyboard when opening menu
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Show the sheet with animation
        withAnimation(.easeInOut(duration: 0.2)) {
            showNotesSheet = true
        }
        
        print("Notes sheet opened")
        
        // Reset toggling state after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isToggling = false
        }
    }
}

// Old SwiftUI bottom sheet components removed - now using UIKit implementation

// All old SwiftUI bottom sheet components removed - replaced with UIKit implementation

struct NoteEditView: View {
    @ObservedObject var note: NoteEntity
    @Environment(\.managedObjectContext) private var viewContext
    @State private var textContent: String = ""
    @State private var saveWorkItem: DispatchWorkItem?
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        TextEditor(text: $textContent)
            .font(DesignSystem.Typography.body)
            .primaryText()
            .focused($isTextFieldFocused)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.top, DesignSystem.Spacing.lg)
            .background(DesignSystem.Colors.primaryBackground)
            .scrollContentBackground(.hidden) // Hide the default white background
            .onChange(of: textContent) { newValue in
                debouncedSave(newValue)
            }
            .onChange(of: note) { newNote in
                // Update content when note changes
                textContent = newNote.body ?? ""
                print("Note changed to: \(newNote.title ?? "No title")")
                
                // Auto-focus keyboard when switching to a new note
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isTextFieldFocused = true
                }
            }
            .onAppear {
                textContent = note.body ?? ""
                print("NoteEditView appeared with note: \(note.title ?? "No title")")
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

// Old FloatingActionButton removed - now using DSFloatingActionButton from DesignSystem

// Note: onPressGesture extension is now defined in DesignSystem.swift

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
