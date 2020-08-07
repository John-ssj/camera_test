//
//  newCameraView.swift
//  camera_test
//
//  Created by 史圣久 on 2020/8/6.
//  Copyright © 2020 史圣久. All rights reserved.
//


import AVFoundation
import Foundation
import UIKit

class newCameraView: UIViewController, AVCapturePhotoCaptureDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var photoOutput: AVCapturePhotoOutput!

    var previewView = UIView()
    var captureImageView = UIImageView()
    var takePicture = UIButton()
    var nextPicture = UIButton()

    var picture_num = 0

    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }

    func setUpView() {
        view.backgroundColor = UIColor.white

        view.addSubview(previewView)
        previewView.backgroundColor = UIColor.black
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        previewView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true

        view.addSubview(captureImageView)
        captureImageView.translatesAutoresizingMaskIntoConstraints = false
        captureImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        captureImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        captureImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        captureImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        captureImageView.contentMode = .scaleAspectFill
        captureImageView.clipsToBounds = true
        captureImageView.alpha = 0

        view.addSubview(takePicture)
//        takePicture.backgroundColor = .white
//        takePicture.layer.cornerRadius = 38
//        takePicture.layer.masksToBounds = true
        takePicture.translatesAutoresizingMaskIntoConstraints = false
        takePicture.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        takePicture.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        takePicture.widthAnchor.constraint(equalToConstant: 75).isActive = true
        takePicture.heightAnchor.constraint(equalToConstant: 75).isActive = true
        takePicture.setBackgroundImage(UIImage(systemName: "largecircle.fill.circle")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        takePicture.addTarget(self, action: #selector(TakePhoto), for: .touchDown)

        view.addSubview(nextPicture)
        nextPicture.translatesAutoresizingMaskIntoConstraints = false
        nextPicture.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        nextPicture.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
        nextPicture.widthAnchor.constraint(equalToConstant: 60).isActive = true
        nextPicture.heightAnchor.constraint(equalToConstant: 40).isActive = true
        nextPicture.setTitle("Next", for: .normal)
        nextPicture.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        nextPicture.setTitleColor(.white, for: .normal)
        nextPicture.setTitleShadowColor(.black, for: .normal)
        nextPicture.addTarget(self, action: #selector(NextPhoto), for: .touchDown)
        nextPicture.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpView()
        setUpCamera()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if captureSession.isRunning == true {
            captureSession.stopRunning()
        }
    }

    func setUpCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        else {
            print("Unable to access back camera!")
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            photoOutput = AVCapturePhotoOutput()
            if captureSession.canAddInput(input) && captureSession.canAddOutput(photoOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(photoOutput)
                setupLivePreview()
            }
        } catch let error {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }

    func setupLivePreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(previewLayer)

        DispatchQueue.global(qos: .userInitiated).async { // [weak self] in
            self.captureSession.startRunning()

            DispatchQueue.main.async {
                self.previewLayer.frame = self.previewView.bounds
            }
        }
    }

    // 拍照按钮
    @objc func TakePhoto() {
//        if !captureSession.isRunning { return }

        previewView.alpha = 0
        captureImageView.alpha = 1
        takePicture.alpha = 0
        nextPicture.alpha = 1

        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoOutput.capturePhoto(with: settings, delegate: self)

        print("take Picture")

//        captureSession.stopRunning()
    }

    // next按钮
    @objc func NextPhoto() {
//        if captureSession.isRunning { return }

//        DispatchQueue.global(qos: .userInitiated).async { // [weak self] in
//            self.captureSession.startRunning()
//
//            DispatchQueue.main.async {
//                self.previewLayer.frame = self.previewView.bounds
//            }
//        }
        picture_num += 1

        previewView.alpha = 1
        captureImageView.alpha = 0
        takePicture.alpha = 1
        nextPicture.alpha = 0
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation()
        else {
            captureSession.startRunning()
            print("error")
            return
        }

        let image = UIImage(data: imageData)
        captureImageView.image = image

        if let imageData = image!.jpegData(compressionQuality: 1) as NSData? {
            let fullPath = NSHomeDirectory().appending("/Documents/").appending("image_\(picture_num)")
            DispatchQueue.global().async {
                imageData.write(toFile: fullPath, atomically: true)
                print("fullPath=\(fullPath)")
            }
        }
    }
}
