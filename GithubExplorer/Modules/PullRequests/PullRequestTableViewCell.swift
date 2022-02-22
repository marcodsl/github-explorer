// PullRequestTableViewCell.swift

import UIKit
import Kingfisher

class PullRequestTableViewCell: UITableViewCell {

    @IBOutlet var avatarImageView: UIImageView!

    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var bodyLabel: UILabel!

    @IBOutlet var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(with pullRequest: PullRequest) {
        authorLabel.text = pullRequest.user.login
        titleLabel.text = pullRequest.title

        bodyLabel.text = pullRequest.body

        dateLabel.text = pullRequest.createdAt.formatted()

        let url = URL(string: pullRequest.user.avatarUrl)!
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
