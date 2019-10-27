//
//  SearchViewController.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/26/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate {

    //MARK: - Outlet
    @IBOutlet private weak var textFieldSearch: UITextField!
    
    //MARK: - Properties
    var textSearch: String = ""
    var searchClouse: ((_ search: String) -> Void)?
    
    //MARK: - View lyfe cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldSearch.text = textSearch
        textFieldSearch.delegate = self
        textFieldSearch.returnKeyType = .search
        textFieldSearch.becomeFirstResponder()
    }
    
    //MARK: - Function
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !textFieldSearch.text!.isEmpty {
            searchClouse?(textFieldSearch.text!)
            self.view.endEditing(true)
            dismiss(animated: true, completion: nil)
        }
        return true
    }
    
    //MARK: - Action
    @IBAction private func btnActionBack(_ sender: Any) {
        textFieldSearch.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction private func btnActionMicro(_ sender: Any) {
    }
    
}
