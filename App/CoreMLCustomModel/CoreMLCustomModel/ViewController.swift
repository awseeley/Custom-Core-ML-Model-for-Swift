//
//  ViewController.swift
//  CoreMLCustomModel
//
//  Created by Andrew Seeley on 18/4/18.
//  Copyright © 2018 Seemu. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imgGuess: UIImageView!
    @IBOutlet var lblGuess: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            lblGuess.text = "Thinking"
            
            // Set the image view
            imgGuess.contentMode = .scaleToFill
            imgGuess.image = pickedImage
            
            // Get the model
            guard let model = try? VNCoreMLModel(for: animals().model) else {
                fatalError("Unable to load model")
            }
            
            // Create vision request
            let request = VNCoreMLRequest(model: model) {[weak self] request, error in
                guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first
                else {
                    fatalError("Unexpected results")
                }
                
                // Update the main UI thread with our result
                DispatchQueue.main.async {[weak self] in
                    self?.lblGuess.text = "\(topResult.identifier) with \(Int(topResult.confidence * 100))% confidence"
                }
            }
            
            guard let ciImage = CIImage(image: pickedImage)
            else { fatalError("Cannot read picked image")}
            
            // Run the classifier
            let handler = VNImageRequestHandler(ciImage: ciImage)
            DispatchQueue.global().async {
                do {
                    try handler.perform([request])
                } catch {
                    print(error)
                }
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }

    @IBAction func takePhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func takePhotoFromCamera(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
}

