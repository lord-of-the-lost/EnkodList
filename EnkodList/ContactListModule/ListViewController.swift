//
//  ListViewController.swift
//  EnkodList
//
//  Created by Николай Игнатов on 14.07.2023.
//

import UIKit

final class ListViewController: UIViewController {
    
    // MARK: - Private properties
    
    private var currentPage: Int = 1
    private var viewModel: ListViewModelProtocol
    
    // MARK: - UI components
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.barTintColor = .systemGray6
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 15
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: "ListTableViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var previousPageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Previous Page", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(previousPageButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var currentPageLabel: UILabel = {
        let label = UILabel()
        label.text = "\(currentPage) page"
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nextPageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next Page", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextPageButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    init() {
        self.viewModel = ListViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupPageLabelGesture()
        setupConstraints()
        bindViewModel()
        viewModel.fetchData()
    }
    
    // MARK: - Setup View
    
    private func setupView() {
        view.backgroundColor = .systemGray6
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(previousPageButton)
        view.addSubview(currentPageLabel)
        view.addSubview(nextPageButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            previousPageButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 35),
            previousPageButton.centerYAnchor.constraint(equalTo: currentPageLabel.centerYAnchor),
            
            currentPageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentPageLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            nextPageButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -35),
            nextPageButton.centerYAnchor.constraint(equalTo: currentPageLabel.centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: currentPageLabel.topAnchor, constant: -20)
        ])
    }
    
    private func setupPageLabelGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pageLabelTapped))
        currentPageLabel.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - ViewModel Binding
    
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func previousPageButtonTapped() {
        if currentPage > 1 {
            currentPage -= 1
            currentPageLabel.text = "\(currentPage) page"
            // Обновление таблицы с новыми данными для предыдущей страницы
        }
    }
    
    @objc private func nextPageButtonTapped() {
        currentPage += 1
        currentPageLabel.text = "\(currentPage) page"
        // Обновление таблицы с новыми данными для следующей страницы
    }
    
    @objc private func pageLabelTapped() {
        let alertController = UIAlertController(title: "Go to page:", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Enter the number"
            textField.keyboardType = .numberPad
        }
        
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            if let textField = alertController.textFields?.first, let text = textField.text, let newPage = Int(text), newPage > 0 {
                self?.currentPage = newPage
                self?.currentPageLabel.text = "\(newPage) page"
                // Обновление таблицы с новыми данными для выбранной страницы
            } else {
                let errorAlertController = UIAlertController(title: "Error", message: "Invalid page value", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                errorAlertController.addAction(okAction)
                self?.present(errorAlertController, animated: true, completion: nil)
            }
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Extensions

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as? ListTableViewCell else {
            return UITableViewCell() }
        
        if let item = viewModel.item(at: indexPath.row) {
            cell.configure(with: item)
        }
        return cell
    }
}

extension ListViewController: UITableViewDelegate {
    
}

extension ListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text?.lowercased() else { return }
        viewModel.filterItems(with: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        viewModel.filterItems(with: "")
        searchBar.resignFirstResponder() //fix
    }
}

