//
//  ListViewController.swift
//  EnkodList
//
//  Created by Николай Игнатов on 14.07.2023.
//

import UIKit

final class ListViewController: UIViewController {
    
    // MARK: - Private properties
    
    private var maxPages: Int = 0
    private var currentPage: Int = 0
    private var lastContentOffset: CGFloat = 0
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
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [previousPageButton, currentPageButton, nextPageButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var previousPageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.addTarget(self, action: #selector(previousPageButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var nextPageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.addTarget(self, action: #selector(nextPageButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var currentPageButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(currentPageButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
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
        setupConstraints()
        bindViewModel()
        viewModel.fetchData()
    }
    
    // MARK: - Setup View
    
    private func setupView() {
        view.backgroundColor = .systemGray6
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(buttonStackView)
        updateCurrentPageButtonTitle()
    }

    // MARK: - ViewModel Binding
    
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.updateMaxPages()
                self.updateCurrentPageButtonTitle()
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func previousPageButtonTapped() {
        if currentPage > 0 {
            currentPage -= 1
            updateCurrentPageButtonTitle()
            updateTableView()
        }
    }
    
    @objc private func nextPageButtonTapped() {
        if currentPage < viewModel.pages.count - 1 {
            currentPage += 1
            updateCurrentPageButtonTitle()
            self.updateTableView()
        }
    }
    
    @objc private func currentPageButtonTapped() {
        let alertController = UIAlertController(title: "Go to page:", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Enter the number"
            textField.keyboardType = .numberPad
        }
        
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            if let textField = alertController.textFields?.first, let text = textField.text, let newPage = Int(text), newPage > 0, newPage <= self.viewModel.pages.count {
                self.currentPage = newPage - 1
                self.updateCurrentPageButtonTitle()
                self.updateTableView()
            } else {
                self.showInvalidPageAlert()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    // MARK: - Helper Methods
    
    private func updateMaxPages() {
        maxPages = viewModel.pages.count
    }

    private func updateCurrentPageButtonTitle() {
        let title = "\(currentPage + 1)/\(maxPages) page"
        currentPageButton.setTitle(title, for: .normal)
    }
    
    private func updateTableView() {
           DispatchQueue.main.async {
               self.tableView.reloadData()
               self.tableView.scrollToTop(animated: true)
           }
       }
}

// MARK: - Extensions

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard currentPage >= 0, currentPage < viewModel.pages.count else {
            return 0
        }
        return viewModel.pages[currentPage].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as? ListTableViewCell else {
            return UITableViewCell() }
        
        if let item = viewModel.item(at: indexPath.row, in: currentPage) {
            cell.configure(with: item)
        }
        
        return cell
    }
}

extension ListViewController: UITableViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let scrollOffset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        if scrollOffset < lastContentOffset && scrollOffset < -10 {
            // Scrolled up
            if currentPage > 0 {
                currentPage -= 1
                updateCurrentPageButtonTitle()
                self.updateTableView()
            }
        } else if scrollOffset > lastContentOffset && scrollOffset > contentHeight - scrollViewHeight + 10 {
            // Scrolled down
            if currentPage < viewModel.pages.count - 1 {
                currentPage += 1
                updateCurrentPageButtonTitle()
                self.updateTableView()
            }
        }
        
        lastContentOffset = scrollOffset
    }
}


extension ListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text?.lowercased() else { return }
        viewModel.filterItems(with: searchText)
        currentPage = 0
        updateCurrentPageButtonTitle()
        view.endEditing(true)
        
        if viewModel.numberOfItems == 0 {
            showNoMatchesAlert()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            viewModel.filterItems(with: "")
            searchBar.resignFirstResponder()
            self.view.becomeFirstResponder()
        }
    }
}

private extension ListViewController {
    
    // MARK: - Error Handling
    
     func showNoMatchesAlert() {
        let alertController = UIAlertController(title: "No Matches", message: "No items found matching your search", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.tableView.scrollToTop(animated: true)
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showInvalidPageAlert() {
        let alertController = UIAlertController(title: "Error", message: "Invalid page value", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Constraints
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -20),

            buttonStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
}
