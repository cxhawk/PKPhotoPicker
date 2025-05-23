//
//  PKPhotoPickerCell.swift
//  PhotoPicker
//
//  Created by Xiang Cao on 4/7/25.
//

import Photos
import UIKit

class PKPhotoPickerCell: UICollectionViewCell {
    var representedAssetIdentifier: String?
    var imageCache: PHCachingImageManager?

    private let scrimView = PKGradientView(colors: [UIColor.black.withAlphaComponent(0.6), UIColor.clear])

    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    let selectionIndicator: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "checkmark.circle.fill")
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = .systemBlue
        iv.isHidden = true
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 1
        iv.layer.cornerRadius = 12
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        return iv
    }()

    let durationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])

        contentView.addSubview(selectionIndicator)
        NSLayoutConstraint.activate([
            selectionIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            selectionIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            selectionIndicator.widthAnchor.constraint(equalToConstant: 24),
            selectionIndicator.heightAnchor.constraint(equalToConstant: 24),
        ])

        contentView.addSubview(durationLabel)
        NSLayoutConstraint.activate([
            durationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            durationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            durationLabel.heightAnchor.constraint(equalToConstant: 20),
        ])

        contentView.insertSubview(scrimView, belowSubview: durationLabel)
        scrimView.isHidden = true
        NSLayoutConstraint.activate([
            scrimView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrimView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrimView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            scrimView.heightAnchor.constraint(equalToConstant: 25),
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.contentMode = .scaleAspectFill
        durationLabel.text = nil
        scrimView.isHidden = true
    }

    override var isSelected: Bool {
        didSet {
            selectionIndicator.isHidden = !isSelected
        }
    }

    func configure(with item: PKPhotoPickerItem, cellImageSize: CGSize) {
        switch item {
        case let .asset(asset):
            representedAssetIdentifier = asset.localIdentifier
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            imageCache?.requestImage(for: asset, targetSize: cellImageSize, contentMode: .aspectFill, options: options) { image, _ in
                if self.representedAssetIdentifier == asset.localIdentifier {
                    self.imageView.image = image
                }
            }
            configureDuration(asset.duration)
        case let .image(image):
            imageView.image = image
        case .video:
            imageView.isHidden = true
        case .camera:
            let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
            imageView.image = UIImage(systemName: "camera", withConfiguration: config)
            imageView.contentMode = .center
        }
    }

    private func configureDuration(_ duration: TimeInterval) {
        if duration > 0 {
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            durationLabel.text = String(format: "%d:%02d", minutes, seconds)
            durationLabel.isHidden = false
        } else {
            durationLabel.isHidden = true
        }
        scrimView.isHidden = durationLabel.isHidden
        scrimView.layer.sublayers?.first?.frame = scrimView.bounds
    }
}
