import UIKit

// MARK: - Note Table View Cell
class NoteTableViewCell: UITableViewCell {
    
    static let identifier = "NoteTableViewCell"
    
    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = 8 // Flatter design with smaller radius
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var iconContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12 // Smaller, flatter icon container
        view.backgroundColor = DesignSystem.Colors.uiSecondaryBackground
        return view
    }()
    
    private lazy var noteIconImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        imageView.image = UIImage(systemName: "doc.text", withConfiguration: config)
        imageView.tintColor = DesignSystem.Colors.uiWarmGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.uiBodyMedium
        label.textColor = DesignSystem.Colors.uiDeepBrown
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var previewLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.uiSubheadline
        label.textColor = DesignSystem.Colors.uiWarmGray
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.uiFootnote
        label.textColor = DesignSystem.Colors.uiWarmGray
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystem.Colors.uiSeparator
        return view
    }()
    
    private var isNoteSelected = false
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        previewLabel.text = nil
        dateLabel.text = nil
        isNoteSelected = false
        updateSelectionState(animated: false)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        let scale: CGFloat = highlighted ? 0.98 : 1.0
        let alpha: CGFloat = highlighted ? 0.8 : 1.0
        
        if animated {
            UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction]) {
                self.containerView.transform = CGAffineTransform(scaleX: scale, y: scale)
                self.containerView.alpha = alpha
            }
        } else {
            containerView.transform = CGAffineTransform(scaleX: scale, y: scale)
            containerView.alpha = alpha
        }
    }
    
    // MARK: - Public Methods
    func configure(with note: NoteEntity, isSelected: Bool) {
        titleLabel.text = note.title ?? "Untitled"
        
        // Configure preview text
        if let body = note.body, !body.isEmpty {
            previewLabel.text = String(body.prefix(100))
            previewLabel.isHidden = false
        } else {
            previewLabel.text = "No additional text"
            previewLabel.isHidden = false
        }
        
        // Configure date
        if let createdAt = note.createdAt {
            dateLabel.text = formatRelativeDate(createdAt)
        } else {
            dateLabel.text = "Unknown date"
        }
        
        // Update selection state
        isNoteSelected = isSelected
        updateSelectionState(animated: true)
    }
    
    // MARK: - Private Setup Methods
    private func setupUI() {
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(iconContainerView)
        iconContainerView.addSubview(noteIconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(previewLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(separatorView)
        
        // Configure Auto Layout
        containerView.translatesAutoresizingMaskIntoConstraints = false
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        noteIconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        previewLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container View
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            
            // Icon Container
            iconContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconContainerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            iconContainerView.widthAnchor.constraint(equalToConstant: 32),
            iconContainerView.heightAnchor.constraint(equalToConstant: 32),
            
            // Note Icon
            noteIconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            noteIconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            
            // Title Label
            titleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: dateLabel.leadingAnchor, constant: -8),
            
            // Date Label
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            dateLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            dateLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            // Preview Label
            previewLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            previewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            previewLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            previewLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16),
            
            // Separator View
            separatorView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    private func updateSelectionState(animated: Bool) {
        let backgroundColor: UIColor = isNoteSelected ? DesignSystem.Colors.uiWarmOrange : UIColor.clear
        let titleColor: UIColor = isNoteSelected ? UIColor.white : DesignSystem.Colors.uiDeepBrown
        let previewColor: UIColor = isNoteSelected ? UIColor.white.withAlphaComponent(0.9) : DesignSystem.Colors.uiWarmGray
        let dateColor: UIColor = isNoteSelected ? UIColor.white.withAlphaComponent(0.8) : DesignSystem.Colors.uiWarmGray
        let iconBackgroundColor: UIColor = isNoteSelected ? UIColor.white.withAlphaComponent(0.2) : DesignSystem.Colors.uiSecondaryBackground
        let iconTintColor: UIColor = isNoteSelected ? UIColor.white : DesignSystem.Colors.uiWarmGray
        let separatorAlpha: CGFloat = isNoteSelected ? 0.0 : 1.0
        
        let updateColors = {
            self.containerView.backgroundColor = backgroundColor
            self.titleLabel.textColor = titleColor
            self.previewLabel.textColor = previewColor
            self.dateLabel.textColor = dateColor
            self.iconContainerView.backgroundColor = iconBackgroundColor
            self.noteIconImageView.tintColor = iconTintColor
            self.separatorView.alpha = separatorAlpha
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction]) {
                updateColors()
            }
        } else {
            updateColors()
        }
    }
    
    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Empty State Table View Cell
class EmptyStateTableViewCell: UITableViewCell {
    
    static let identifier = "EmptyStateTableViewCell"
    
    // MARK: - UI Components
    private lazy var emptyIconImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .ultraLight)
        imageView.image = UIImage(systemName: "doc.text", withConfiguration: config)
        imageView.tintColor = DesignSystem.Colors.uiWarmGray.withAlphaComponent(0.6)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "No Notes Yet"
        label.font = DesignSystem.Typography.uiTitle3
        label.textColor = DesignSystem.Colors.uiDeepBrown
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var emptySubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap 'New Note' to create your first note"
        label.font = DesignSystem.Typography.uiSubheadline
        label.textColor = DesignSystem.Colors.uiWarmGray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emptyIconImageView, emptyTitleLabel, emptySubtitleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        return stack
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Setup Methods
    private func setupUI() {
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -32),
            
            emptyIconImageView.heightAnchor.constraint(equalToConstant: 50),
            emptyIconImageView.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
} 