//
//  ViewController.swift
//  MLProject
//
//  Created by Mateusz Łukasiński on 12/01/2020.
//  Copyright © 2020 Mateusz Łukasiński. All rights reserved.
//

import UIKit
import AVKit

class InitialViewController: UIViewController {
    
    //variables
    private var hasAccess:Bool = false
    
    //IBActions:
    @IBAction func firstOptionSelected(_ sender: UIButton) {
        if hasAccess{
            performSegue(withIdentifier: "InitialToCamera", sender: self)
        }else{
            checkIfHasPermission()
        }
        
    }
    
    //Outlets
    @IBOutlet weak var firstOptionButton: UIButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfHasPermission()
    }

    //Utils functions
    private func checkIfHasPermission(){
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { (response) in
            if response{
                print("IS ENABLED")
                self.hasAccess = true
            }
            else{
                print("ISNOTENABLED")
                self.hasAccess = false
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController.init(title: "You Need Permission for camera", message: "Please enable camera usage in settings", preferredStyle: .alert)
                    let okAction = UIAlertAction.init(title: "OK", style: .default) { (action) in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                    
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    
}


