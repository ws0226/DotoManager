//
//  CalendarTodoItemCell.swift
//  My Manager
//
//  Created by Woosol Hwang on 09/06/24.
//

import UIKit

class CalendarTodoItemCell: UITableViewCell {
    let courseNameLabel = UILabel()
    let titleLabel = UILabel()
    let dueDateLabel = UILabel()
    
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
        
        dueDateLabel.font = UIFont.systemFont(ofSize: 12)
        dueDateLabel.textColor = .gray
        
        courseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dueDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(courseNameLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dueDateLabel)
        
        NSLayoutConstraint.activate([
            courseNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            courseNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            courseNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: courseNameLabel.bottomAnchor, constant: 4),
            
            dueDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dueDateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            dueDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with item: TodoItem) {
        courseNameLabel.text = item.courseName
        titleLabel.text = item.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        dueDateLabel.text = "Due: \(dateFormatter.string(from: item.dueDate))"
        
        let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: item.dueDate).day ?? 0
        
        // Set background color based on submission or attendance status
        if item.isFinished {
            contentView.backgroundColor = UIColor.green.withAlphaComponent(0.3)
        } else if daysLeft <= 0 {
            contentView.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        } else {
            contentView.backgroundColor = UIColor.yellow.withAlphaComponent(0.3)
        }
    }

}
