//
//  SearchViewController.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/26/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import UIKit

final class SearchViewController: UIViewController, UITextFieldDelegate {

    //MARK: - Outlet
    @IBOutlet weak var textFieldSearch: UITextField!
    @IBOutlet private weak var btnMicro: UIButton!
    @IBOutlet private weak var listSearchTableView: UITableView!
    @IBOutlet private weak var heightTableView: NSLayoutConstraint!
    
    //MARK: - Properties
    var textSearch: String = Constants.empty
    var arrSearch: [String] = []
    var searchClouse: ((_ search: String) -> Void)?
    var arrSearchClosures: ((_ arrSearch:[String], _ topgraphic: Topgraphic) -> Void)?
    var topgraphic: Topgraphic = .normal
    
    //MARK: - View lyfe cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
    }
    
    //MARK: - Function
    private func configUI() {
        UIApplication.shared.statusBarStyle = .default
        
        textFieldSearch.text = textSearch
        textFieldSearch.delegate = self
        textFieldSearch.returnKeyType = .search
        textFieldSearch.becomeFirstResponder()
        textFieldSearch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        listSearchTableView.delegate = self
        listSearchTableView.dataSource = self
        listSearchTableView.register(UINib(nibName: SearchTableViewCell.name, bundle: nil), forCellReuseIdentifier: SearchTableViewCell.name)
        
        if textSearch.isEmpty {
            btnMicro.setImage(UIImage(named: "imv_microphone"), for: .normal)
        } else {
            btnMicro.setImage(UIImage(named: "imv_clear"), for: .normal)
        }
        
        listSearchTableView.reloadData()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let search = textFieldSearch.text {
            if search.isEmpty {
                btnMicro.setImage(UIImage(named: "imv_microphone"), for: .normal)
            } else {
                btnMicro.setImage(UIImage(named: "imv_clear"), for: .normal)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let search = textFieldSearch.text else {
            return true
        }
        
        if !search.isEmpty {
            arrSearch.insert(search, at: 0)
            searchClouse?(search)
            arrSearchClosures?(arrSearch, topgraphic)
            view.endEditing(true)
            dismiss(animated: true, completion: nil)
        }
        
        return true
    }
    
    //MARK: - Action
    @IBAction private func btnActionBack(_ sender: Any) {
        arrSearchClosures?(arrSearch, topgraphic)
        textFieldSearch.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func btnActionMicro(_ sender: Any) {
        guard let checkImage = btnMicro.currentImage?.isEqual(UIImage(named: "imv_microphone")) else {
            return
        }
        
        if !checkImage {
            textFieldSearch.text = nil
            btnMicro.setImage(UIImage(named: "imv_microphone"), for: .normal)
        }
    }
}

//MARK: - UITableViewDataSource + UITableViewDelegate
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchClouse?(arrSearch[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSearch.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.name, for: indexPath) as? SearchTableViewCell else {
            return UITableViewCell()
        }
        
        cell.fillData(textSearch: arrSearch[indexPath.row])
        cell.deleteClouse = { [weak self] in
            guard let wSelf = self else {return}
            wSelf.arrSearch.remove(at: indexPath.row)
            wSelf.listSearchTableView.reloadData()
        }
        
        return cell
    }
}
