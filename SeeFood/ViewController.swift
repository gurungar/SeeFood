//
//  ViewController.swift
//  SeeFood
//
//  Created by Arjun Gurung on 8/7/18.
//  Copyright © 2018 Arjun Gurung. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            
        imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Couldnt convert UIImage to CIImage.")
            }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreMLModel Failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model Failed to process image.")
            }
            
            /*if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "HotDog!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.green
                    self.navigationController?.navigationBar.isTranslucent = false
                    
                }
                else {
                    self.navigationItem.title = "Not HotDog."
                    self.navigationController?.navigationBar.barTintColor = UIColor.red
                    self.navigationController?.navigationBar.isTranslucent = false
                }
            }*/
            if let firstResult = results.first {
                self.navigationItem.title = "Found It!"
                if firstResult.confidence*100 > 80.0 {
                    self.textLabel.text = "It is a " +  firstResult.identifier
                }
                else if firstResult.confidence * 100 > 50.0 {
                    self.textLabel.text = "I am fairly confident it is a " +  firstResult.identifier
                }
                else if firstResult.confidence * 100 > 20.0 {
                    self.textLabel.text = "It may be a " +  firstResult.identifier
                }
                else {
                    self.textLabel.text = "Wild guess! It is a " +  firstResult.identifier + "?"
                }
            }
            else {
                self.textLabel.text = "I dont know either!"
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
 
}

