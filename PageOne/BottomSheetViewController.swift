import UIKit
import SwiftUI

// MARK: - Bottom Sheet Delegate Protocol
protocol BottomSheetDelegate: AnyObject {
    func bottomSheetDidSelectNote(_ note: NoteEntity)
    func bottomSheetDidRequestDismissal()
    func bottomSheetDidRequestNewNote()
    func bottomSheetDidDeleteNote(_ note: NoteEntity)
}

// MARK: - Bottom Sheet View Controller
class BottomSheetViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: BottomSheetDelegate?
    private var notes: [NoteEntity] = []
    private var selectedNote: NoteEntity?
    
    // UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = DesignSystem.Colors.uiPrimaryBackground
        table.showsVerticalScrollIndicator = false
        table.contentInsetAdjustmentBehavior = .automatic
        table.register(NoteTableViewCell.self, forCellReuseIdentifier: NoteTableViewCell.identifier)
        table.register(EmptyStateTableViewCell.self, forCellReuseIdentifier: EmptyStateTableViewCell.identifier)
        return table
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystem.Colors.uiPrimaryBackground
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Notes"
        label.font = DesignSystem.Typography.uiLargeTitle
        label.textColor = DesignSystem.Colors.uiDeepBrown
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = DesignSystem.Colors.uiWarmGray
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var newNoteButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "New Note"
        config.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .medium))
        config.imagePlacement = .leading
        config.imagePadding = 6
        config.cornerStyle = .medium
        config.buttonSize = .medium
        config.baseBackgroundColor = DesignSystem.Colors.uiWarmOrange
        config.baseForegroundColor = UIColor.white
        
        button.configuration = config
        button.addTarget(self, action: #selector(newNoteButtonTapped), for: .touchUpInside)
        button.isHidden = true  // Hide the New Note button
        return button
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystem.Colors.uiSeparator
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        configureSheetPresentation()
        addHapticFeedback()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateAppearance()
    }
    
    // MARK: - Public Methods
    func configure(with notes: [NoteEntity], selectedNote: NoteEntity?) {
        self.notes = notes
        self.selectedNote = selectedNote
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            self?.scrollToSelectedNote()
        }
    }
    
    // MARK: - Private Setup Methods
    private func setupUI() {
        view.backgroundColor = DesignSystem.Colors.uiPrimaryBackground
        
        // Add subviews
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(closeButton)
        headerView.addSubview(separatorView)
        view.addSubview(tableView)
        
        // Configure table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header View
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 80),
            
            // Title Label
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: -5),
            
            // Close Button
            closeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Separator
            separatorView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            separatorView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            // Table View
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureSheetPresentation() {
        guard let sheet = sheetPresentationController else { return }
        
        // Configure detents for two-stage expansion
        sheet.detents = [.medium(), .large()]
        
        // Enable grabber (drag indicator)
        sheet.prefersGrabberVisible = true
        
        // Configure scroll behavior - prevents automatic expansion when scrolling
        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        
        // Edge attachment for landscape support
        sheet.prefersEdgeAttachedInCompactHeight = true
        
        // Width follows preferred content size when edge attached
        sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        
        // Enable dismiss on background tap
        isModalInPresentation = false
        
        // Custom corner radius
        sheet.preferredCornerRadius = 16
        
        // Set initial detent to medium
        sheet.selectedDetentIdentifier = .medium
        
        // Note: Delegate is set by the container that presents this view controller
    }
    
    private func addHapticFeedback() {
        // Add haptic feedback for sheet presentation
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
    }
    
    private func animateAppearance() {
        // Animate header elements
        titleLabel.alpha = 0
        closeButton.alpha = 0
        tableView.alpha = 0
        
        UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) { [weak self] in
            self?.titleLabel.alpha = 1
            self?.closeButton.alpha = 1
            self?.tableView.alpha = 1
        }
    }
    
    private func scrollToSelectedNote() {
        guard let selectedNote = selectedNote,
              let index = notes.firstIndex(of: selectedNote),
              !notes.isEmpty else { return }
        
        let indexPath = IndexPath(row: index, section: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }
    
    // MARK: - Action Methods
    @objc private func closeButtonTapped() {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
        impactFeedback.impactOccurred()
        
        delegate?.bottomSheetDidRequestDismissal()
        dismiss(animated: true)
    }
    
    @objc private func newNoteButtonTapped() {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        delegate?.bottomSheetDidRequestNewNote()
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension BottomSheetViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.isEmpty ? 1 : notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if notes.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: EmptyStateTableViewCell.identifier, for: indexPath) as! EmptyStateTableViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.identifier, for: indexPath) as! NoteTableViewCell
            let note = notes[indexPath.row]
            let isSelected = note == selectedNote
            cell.configure(with: note, isSelected: isSelected)
            
            // Set up delete callback
            cell.onDeleteTapped = { [weak self] in
                self?.confirmDeleteNote(note)
            }
            
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension BottomSheetViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard !notes.isEmpty else { return }
        
        let note = notes[indexPath.row]
        
        // Add haptic feedback for selection
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        
        // Update selection immediately for visual feedback
        selectedNote = note
        tableView.reloadData()
        
        // Notify delegate after brief delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.delegate?.bottomSheetDidSelectNote(note)
            self?.dismiss(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return notes.isEmpty ? 200 : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return notes.isEmpty ? 200 : 80
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard !notes.isEmpty else { return nil }
        
        let note = notes[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.deleteNote(note)
            }
            
            return UIMenu(title: "", children: [deleteAction])
        }
    }
    
    private func confirmDeleteNote(_ note: NoteEntity) {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        let alert = UIAlertController(
            title: "Delete Note",
            message: "Are you sure you want to delete this note? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteNote(note)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true)
    }
    
    private func deleteNote(_ note: NoteEntity) {
        guard let index = notes.firstIndex(of: note) else { return }
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Remove from local array
        notes.remove(at: index)
        
        // Update table view with animation
        let indexPath = IndexPath(row: index, section: 0)
        
        if notes.isEmpty {
            tableView.reloadData()
        } else {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        // Update selected note if necessary
        if selectedNote == note {
            selectedNote = notes.first
        }
        
        // Delegate the actual Core Data deletion to the parent
        delegate?.bottomSheetDidDeleteNote(note)
    }
}

// MARK: - Detent Change Handling
extension BottomSheetViewController {
    // Note: Presentation dismissal is handled by the container
    // This method can be called by the container when detent changes occur
    func handleDetentChange() {
        // Add subtle haptic feedback when changing detents
        let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
        impactFeedback.impactOccurred()
    }
}

// MARK: - UIViewController Extension for Easy Presentation
extension UIViewController {
    func presentBottomSheet(with notes: [NoteEntity], selectedNote: NoteEntity?, delegate: BottomSheetDelegate?) {
        let bottomSheet = BottomSheetViewController()
        bottomSheet.delegate = delegate
        bottomSheet.configure(with: notes, selectedNote: selectedNote)
        
        present(bottomSheet, animated: true)
    }
} 