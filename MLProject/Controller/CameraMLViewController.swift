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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainView()
        setupCamera()
        setupViewForOutput()
    }
    
    // SETUP VIEWS:
    
    private func setupMainView(){
        view.backgroundColor = .white
    }
    
    private func setupCamera(){
        let capture = AVCaptureSession()
        capture.sessionPreset = .photo
        
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
        guard let MLmodel = try? VNCoreMLModel(for: SqueezeNet().model) else {return}
        
        let request = VNCoreMLRequest(model: MLmodel) { (request, error) in
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
    
    
    private func setupViewForOutput(){
        let screenSize:CGRect = UIScreen.main.bounds
        let outputView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 100))
        view.addSubview(outputView)
        outputView.backgroundColor = .orange
    }
    
    //Utils function
    private func changeLabelValue(firstValue:VNClassificationObservation, secondValue:VNClassificationObservation){
        let firstIdentifier     = firstValue.identifier
        let firstConfidence     = firstValue.confidence
        let secondIdentifier    = secondValue.identifier
        let secondConfidence    = secondValue.confidence
        
        print("First guess = \(firstIdentifier) with \(firstConfidence) confidence ")
        print("Second guess = \(secondIdentifier) with \(secondConfidence) confidence ")
        
    }
    

}
