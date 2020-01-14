//
//  SplashViewController.swift
//  GoogleMap
//
//  Created by Duy Liêm on 1/6/20.
//  Copyright © 2020 DuyLiem. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    @IBOutlet weak var imvSplash: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: "https://dienmaygiangnam.com/frontend/img/common/icons/nexus2cee_Maps.png")
        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        imvSplash.image = UIImage(data: data!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let homeVC = HomeViewController()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
               let window = appDelegate.window else {
            return
        }
        window.backgroundColor = .white
        window.rootViewController = homeVC
        window.makeKeyAndVisible()
        
    }

}
