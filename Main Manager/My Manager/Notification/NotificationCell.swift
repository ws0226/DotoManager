//
//  NotificationCell.swift
//  My Manager
//
//  Created by Woosol Hwang on 09/06/24.
//
import UIKit

class NotificationCell: UITableViewCell {
    let courseNameLabel = UILabel()
    let titleLabel = UILabel()
    let typeLabel = UILabel()
    let notificationDateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    func setupViews() {
        courseNameLabel.font = UIFont.systemFont(ofSize: 10)
        courseNameLabel.textColor = .gray
        
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        
        typeLabel.font = UIFont.systemFont(ofSize: 12)
        typeLabel.textColor = .gray
        
        notificationDateLabel.font = UIFont.systemFont(ofSize: 12)
        notificationDateLabel.textColor = .gray
        
        courseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(courseNameLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(typeLabel)
        contentView.addSubview(notificationDateLabel)
        
        NSLayoutConstraint.activate([
            courseNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            courseNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            courseNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: courseNameLabel.bottomAnchor, constant: 4),
            
            typeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            typeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            notificationDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            notificationDateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            typeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            notificationDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with item: NotificationItem) {
        courseNameLabel.text = item.courseName
        titleLabel.text = item.name
        typeLabel.text = item.type
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        notificationDateLabel.text = dateFormatter.string(from: item.triggerDate)
    }
}
