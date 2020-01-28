//
//  ViewController.swift
//  MLProject
//
//  Created by Mateusz Łukasiński on 12/01/2020.
//  Copyright © 2020 Mateusz Łukasiński. All rights reserved.
//

import UIKit
import AVKit
import Vision

class InitialViewController: UIViewController {
    
    //variables
    private var hasAccess:Bool = false
    private var buttonPressedTag:Int = 0
    
    //IBActions:
    @IBAction func buttonPressed(_ sender: UIButton) {
        if hasAccess{
            buttonPressedTag = sender.tag
            performSegue(withIdentifier: "InitialToCamera", sender: self)
        }else{
            checkIfHasPermission()
        }
        
    }
    
    

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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "InitialToCamera"{
            let view = segue.destination as! CameraMLViewController
            do {
                if buttonPressedTag == 1{
                    view.Model = try VNCoreMLModel(for: SqueezeNet().model)
                }else if buttonPressedTag == 2 {
                    view.Model = try VNCoreMLModel(for: Resnet50().model)
                } else if buttonPressedTag == 3{
                    view.Model = try VNCoreMLModel(for: MachineLearningModel().model) // self-made ML Model 
                }
            } catch {
                print(error.localizedDescription)
            }

        }
    }
    
    
    
}


