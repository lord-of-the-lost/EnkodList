//
//  ListTableViewCell.swift
//  EnkodList
//
//  Created by Николай Игнатов on 17.07.2023.
//

import UIKit

final class ListTableViewCell: UITableViewCell {
    
    // MARK: - UI components
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let idLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        addSubview(nameLabel)
        addSubview(idLabel)
        addSubview(emailLabel)
        addSubview(dateLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            
            idLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 4),
            idLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            idLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            
            dateLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with item: Item) {
        idLabel.text = "ID: \(item.id ?? 0)"
        emailLabel.text = "Email: \(item.cleanEmail ?? "email not found")"
        nameLabel.text = "Name: \(item.firstName ?? "first name not found") \(item.lastName ?? "last name not found")"
        dateLabel.text = "Last Updated: \(item.formattedDateUpdate ?? "not found")"
    }
}
