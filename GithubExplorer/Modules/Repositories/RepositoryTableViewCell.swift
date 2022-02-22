// RepositoryTableViewCell.swift

import UIKit
import Kingfisher

class RepositoryTableViewCell: UITableViewCell {

    @IBOutlet var avatarImageView: UIImageView!

    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!

    @IBOutlet var stargazersLabel: UILabel!
    @IBOutlet var forksLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(with repository: Repository) {
        nameLabel.text = repository.name
        authorLabel.text = repository.owner.login
        descriptionLabel.text = repository.description

        stargazersLabel.text = repository.stargazersCount.formattedValue
        forksLabel.text = repository.forksCount.formattedValue

        let url = URL(string: repository.owner.avatarUrl)!
        let processor = DownsamplingImageProcessor(size: avatarImageView.bounds.size)
        |> RoundCornerImageProcessor(cornerRadius: 5)

        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(with: url, options: [
            .processor(processor),
            .scaleFactor(UIScreen.main.scale),
            .transition(.fade(1)),
            .cacheOriginalImage
        ])
    }

}
