//
//  CameraMLViewController.swift
//  MLProject
//
//  Created by Mateusz Łukasiński on 14/01/2020.
//  Copyright © 2020 Mateusz Łukasiński. All rights reserved.
//

import UIKit
import AVKit
import Vision

//import CoreML

class CameraMLViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    //OUTLETS:
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    //IBActions
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //Variables:
    var Model:VNCoreMLModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainView()
        setupCamera()
    }
    
    // SETUP VIEWS:
    
    private func setupMainView(){
        view.backgroundColor = .white
    }
    
    private func setupCamera(){
        let capture = AVCaptureSession()
//        capture.sessionPreset = .hd4K3840x2160
        
        guard let device = AVCaptureDevice.default(for: .video) else {return}
        guard let input = try? AVCaptureDeviceInput(device: device) else {return}
        
        capture.addInput(input)
        capture.startRunning()
    
        let previewLayer = AVCaptureVideoPreviewLayer(session: capture)
        
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoData"))
        capture.addOutput(dataOutput)
        
    }
    
    //Function from delegate that is called by every frame
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pb:CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        let MLModel = Model!

        
        let request = VNCoreMLRequest(model: MLModel) { (request, error) in
            if error == nil{
                guard let results = request.results as? [VNClassificationObservation] else {return}
                self.changeLabelValue(firstValue: results[0], secondValue: results[1])
            } else{
                print(error!.localizedDescription)
            }
        }
        
        do {
            try VNImageRequestHandler(cvPixelBuffer: pb,  options: [:]).perform([request])
        } catch{
            print(error.localizedDescription)
        }
    }
    
    
    
    //Utils function
    private func changeLabelValue(firstValue:VNClassificationObservation, secondValue:VNClassificationObservation){
        
        let firstIdentifier     = firstValue.identifier
        let firstConfidence     = String(format: "%.2f", Float(firstValue.confidence)*100)
        let secondIdentifier    = secondValue.identifier
        let secondConfidence    = String(format: "%.2f", Float(secondValue.confidence)*100)
        
        DispatchQueue.main.async {
            self.secondLabel.text = "\(firstIdentifier) with \(firstConfidence) %"
            self.firstLabel.text = "\(secondIdentifier) with \(secondConfidence) %"
        }
        
    }
    

}
