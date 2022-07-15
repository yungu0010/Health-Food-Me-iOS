//
//  SearchVC.swift
//  HealthFoodMe
//
//  Created by 김영인 on 2022/07/05.
//

import UIKit

import RealmSwift
import SnapKit

enum SearchType {
    case recent
    case search
    case searchResult
}

final class SearchVC: UIViewController {
    
    // MARK: - Properties
    
    let realm = try? Realm()
    var searchType: SearchType = SearchType.recent {
        didSet {
            searchTableView.reloadData()
        }
    }
    var searchRecentList: [String] = []
    private var isEmpty: Bool = false
    private var searchEmptyView = SearchEmptyView()
    
    private let searchView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainRed
        return view
    }()
    
    private lazy var searchTextField: UITextField = {
        let tf = UITextField()
        tf.leftViewMode = .always
        tf.rightViewMode = .never
        tf.enablesReturnKeyAutomatically = true
        tf.attributedPlaceholder = NSAttributedString(string: I18N.Search.search, attributes: [NSAttributedString.Key.foregroundColor: UIColor.helfmeTagGray])
        tf.font = .NotoRegular(size: 15)
        tf.textColor = .helfmeBlack
        tf.backgroundColor = .helfmeWhite
        tf.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        tf.leftView = backButton
        return tf
    }()
    
    private lazy var backButton: UIButton = {
        let btn = UIButton()
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 12)
        btn.setImage(ImageLiterals.Search.beforeIcon, for: .normal)
        btn.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return btn
    }()
    
    private lazy var clearButton: UIButton = {
        let btn = UIButton()
        btn.setImage(ImageLiterals.Search.textDeleteBtn, for: .normal)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        btn.addTarget(self, action: #selector(didTapClearButton), for: .touchUpInside)
        return btn
    }()
    
    private lazy var resultCloseButton: UIButton = {
        let btn = UIButton()
        btn.setImage(ImageLiterals.Search.xIcon, for: .normal)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        btn.addTarget(self, action: #selector(popToMainMapVC), for: .touchUpInside)
        return btn
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .helfmeLineGray
        return view
    }()
    
    private let searchHeaderView: UIView = UIView()
    
    private let recentHeaderLabel: UILabel = {
        let lb = UILabel()
        lb.text = I18N.Search.searchRecent
        lb.textColor = .helfmeGray1
        lb.font = .NotoRegular(size: 14)
        return lb
    }()
    
    private lazy var resultHeaderButton: UIButton = {
        let btn = UIButton()
        btn.setImage(ImageLiterals.Search.viewMapBtn, for: .normal)
        btn.setTitle(I18N.Search.searchMap, for: .normal)
        btn.setTitleColor(UIColor.helfmeGray1, for: .normal)
        btn.titleLabel?.font = .NotoRegular(size: 14)
        btn.isHidden = true
        btn.addTarget(self, action: #selector(pushToSearchResultVC), for: .touchUpInside)
        btn.semanticContentAttribute = .forceLeftToRight
        btn.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 10)
        return btn
    }()
    
    private lazy var searchTableView: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.rowHeight = 56
        tv.backgroundColor = .helfmeWhite
        tv.keyboardDismissMode = .onDrag
        tv.tableHeaderView = searchHeaderView
        tv.tableHeaderView?.frame.size.height = 56
        return tv
    }()
    
    // MARK: - View Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        initTextField()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setData()
        setUI()
        setLayout()
        setDelegate()
        registerCell()
    }
}

// MARK: - @objc Methods

extension SearchVC {
    @objc func didTapBackButton() {
        switch searchType {
        case .recent:
            navigationController?.popViewController(animated: true)
        case .search:
            navigationController?.popViewController(animated: true)
        case .searchResult:
            isSearchRecent()
            initTextField()
        }
    }
    
    @objc func didTapClearButton() {
        searchTextField.text?.removeAll()
        isSearchRecent()
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        if searchTextField.isEmpty {
            isSearchRecent()
        } else {
            searchTextField.rightViewMode = .always
            isSearch()
        }
    }
    
    @objc func pushToSearchResultVC() {
        let searchResultVC = ModuleFactory.resolve().makeSearchResultVC()
        searchResultVC.delegate = self
        if let searchText = searchTextField.text {
            searchResultVC.searchContent = searchText
        }
        navigationController?.pushViewController(searchResultVC, animated: false)
    }
    
    @objc func popToMainMapVC() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Methods

extension SearchVC {
    private func initTextField() {
        if searchType == .recent {
            searchTextField.text?.removeAll()
        }
    }
    
    private func setData() {
        let savedSearchRecent = realm?.objects(SearchRecent.self)
        savedSearchRecent?.forEach { object in
            searchRecentList.insert(object.title, at: 0)
        }
    }
    
    private func setUI() {
        view.backgroundColor = .helfmeWhite
        dismissKeyboard()
        self.navigationController?.isNavigationBarHidden = true
        searchTextField.text?.removeAll()
        searchEmptyView.isHidden = true
    }
    
    private func setLayout() {
        view.addSubviews(searchTextField,
                         lineView,
                         searchView,
                         searchEmptyView)
        
        searchTextField.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(56)
        }
        
        backButton.snp.makeConstraints {
            $0.height.equalTo(24)
            $0.width.equalTo(56)
        }
        
        clearButton.snp.makeConstraints {
            $0.height.equalTo(24)
            $0.width.equalTo(40)
        }
        
        resultCloseButton.snp.makeConstraints {
            $0.height.equalTo(24)
            $0.width.equalTo(44)
        }
        
        lineView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(1)
        }
        
        searchHeaderView.addSubviews(recentHeaderLabel, resultHeaderButton)
        
        recentHeaderLabel.snp.makeConstraints {
            $0.top.equalTo(searchHeaderView.snp.top).offset(20)
            $0.leading.equalTo(searchHeaderView.snp.leading).inset(20)
        }
        
        resultHeaderButton.snp.makeConstraints {
            $0.trailing.equalTo(searchHeaderView.snp.trailing).inset(20)
            $0.centerY.equalTo(searchHeaderView)
            $0.width.equalTo(105)
            $0.height.equalTo(20)
        }
        
        searchView.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        searchView.addSubviews(searchTableView)
        
        searchTableView.snp.makeConstraints {
            $0.edges.equalTo(searchView)
        }
        
        searchEmptyView.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setDelegate() {
        searchTextField.delegate = self
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
    }
    
    private func registerCell() {
        SearchRecentTVC.register(target: searchTableView)
        SearchTVC.register(target: searchTableView)
        SearchResultTVC.register(target: searchTableView)
    }
    
    func addSearchRecent(title: String) {
        try? realm?.write {
            if let savedSearchRecent = realm?.objects(SearchRecent.self).filter("title == '\(title)'") {
                realm?.delete(savedSearchRecent)
                searchRecentList = searchRecentList.filter { $0 != title }
            }
            let searchRecent = SearchRecent()
            searchRecent.title = title
            realm?.add(searchRecent)
        }
        searchRecentList.insert(title, at: 0)
    }
    
    private func isSearchRecent() {
        searchTextField.rightViewMode = .never
        searchTableView.tableHeaderView = searchHeaderView
        searchTableView.tableHeaderView?.frame.size.height = 56
        recentHeaderLabel.isHidden = false
        resultHeaderButton.isHidden = true
        searchEmptyView.isHidden = true
        searchType = .recent
    }
    
    private func isSearch() {
        searchTextField.rightView = clearButton
        searchTextField.becomeFirstResponder()
        searchTableView.tableHeaderView = nil
        searchEmptyView.isHidden = true
        searchType = .search
    }
    
    private func isSearchResult() {
        if SearchDataModel.sampleSearchData.isEmpty {
            isEmpty = true
            isSearchEmpty()
        } else {
            searchTextField.resignFirstResponder()
            if let text = searchTextField.text {
                if !SearchDataModel.sampleSearchData.isEmpty {
                    addSearchRecent(title: text)
                }
            }
            searchTextField.rightView = resultCloseButton
            searchTableView.tableHeaderView = searchHeaderView
            searchTableView.tableHeaderView?.frame.size.height = 42
            recentHeaderLabel.isHidden = true
            resultHeaderButton.isHidden = false
            searchType = .searchResult
        }
    }
    
    private func isSearchEmpty() {
        if isEmpty {
            searchEmptyView.isHidden = false
        } else {
            searchEmptyView.isHidden = true
        }
    }
}

// MARK: - UITextFieldDelegate

extension SearchVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        isSearchResult()
        isSearchEmpty()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if searchType == .searchResult {
            isSearch()
        }
    }
}

// MARK: - UITableViewDelegate

extension SearchVC: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource

extension SearchVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch searchType {
        case .recent:
            return searchRecentList.count
        case .search:
            return SearchDataModel.sampleSearchData.count
        case .searchResult:
            return SearchResultDataModel.sampleSearchResultData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch searchType {
        case .recent:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchRecentTVC.className, for: indexPath) as? SearchRecentTVC else { return UITableViewCell() }
            cell.setData(data: searchRecentList[indexPath.row])
            cell.index = indexPath.row
            cell.delegate = self
            return cell
        case .search:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTVC.className, for: indexPath) as? SearchTVC else { return UITableViewCell() }
            cell.setData(data: SearchDataModel.sampleSearchData[indexPath.row])
            return cell
        case .searchResult:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTVC.className, for: indexPath) as? SearchResultTVC else { return UITableViewCell() }
            cell.setData(data: SearchResultDataModel.sampleSearchResultData[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch searchType {
        case .recent:
            return 56
        case .search:
            return 56
        case .searchResult:
            return 127
        }
    }
}

// MARK: - SearchTVCDelegate

extension SearchVC: SearchRecentTVCDelegate {
    func searchRecentTVCDelete(index: Int) {
        try? realm?.write {
            if let savedSearchRecent =  realm?.objects(SearchRecent.self).filter("title == '\(searchRecentList[index])'") {
                realm?.delete(savedSearchRecent)
            }
        }
        searchRecentList.remove(at: index)
        searchTableView.reloadData()
    }
}

// MARK: - SearchResultVCDelegate

extension SearchVC: SearchResultVCDelegate {
    func searchResultVCSearchType(type: SearchType) {
        if type == .search {
            clearButton.isHidden = false
            searchTextField.becomeFirstResponder()
        } else {
            isSearchRecent()
        }
    }
}

// MARK: - Network
