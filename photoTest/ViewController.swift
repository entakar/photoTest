//
//  ViewController.swift
//  photoTest
//
//  Created by EndoTakashi on 2016/05/11.
//  Copyright © 2016年 tak. All rights reserved.
//

import UIKit
import Social

class ViewController: UIViewController,
UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    //twitter用view
    var myComposeView : SLComposeViewController!
    
    let _CAMERA = 0
    let _READ   = 1
    let _WRITE  = 2
    let _CLEAR  = 3
    
    var _imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var readButton: UIButton!
    @IBOutlet weak var writeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let dx: CGFloat = (UIScreen.mainScreen().bounds.size.width - 320) / 2

        let xx: CGFloat = (UIScreen.mainScreen().bounds.size.width) / 4
        let yy: CGFloat = (UIScreen.mainScreen().bounds.size.height) / 4
        
        let dx: CGFloat = (UIScreen.mainScreen().bounds.size.width) / 2
        let dy: CGFloat = (UIScreen.mainScreen().bounds.size.height) / 2
        //イメージビュー生成
        _imageView = makeImageView(CGRectMake(xx , yy, dx,dy), image: nil)
        view.addSubview(_imageView)
    }

    @IBAction func onClick(sender: UIButton){
        if sender.tag == _CAMERA{
            openPicker(UIImagePickerControllerSourceType.Camera)
            print ("CAMERA")
        }else if sender.tag == _READ{
            openPicker(UIImagePickerControllerSourceType.PhotoLibrary)
            print ("READ")
        }else if sender.tag == _WRITE{
            print ("WRITE")
            let image = _imageView.image
            if image == nil{
                return
            }
            //イメージファイルの書き込み
            UIImageWriteToSavedPhotosAlbum(
                image!,
                self,
                nil,
                nil)
        }else if sender.tag == _CLEAR{
            _imageView.image = nil
        }
        
    }
    
    func makeImageView(frame: CGRect, image: UIImage?) -> UIImageView{
        let imageView = UIImageView()
        imageView.frame = frame
        imageView.image = image
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        return imageView
    }
    
    //アラートの表示
    func showAlert(title: String?, text: String?) {
        let alert = UIAlertController(title: title, message: text,
                                      preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK",
            style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //====================
    //イメージピッカーのオープン
    //====================
    //イメージピッカーのオープン
    func openPicker(sourceType: UIImagePickerControllerSourceType) {
        //カメラとフォトアルバムの利用可能チェック(1)
        if !UIImagePickerController.isSourceTypeAvailable(sourceType) {
            showAlert(nil, text: "利用できません")
            return
        }
        
        //イメージピッカーの生成(2)
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        
        //ビューコントローラのビューを開く
        presentViewController(picker, animated: true, completion: nil)
    }
    
    //フォト書き込み完了時に呼ばれる(6)
    func finishExport(image: UIImage,
                      didFinishSavingWithError error: NSError?,
                                               contextInfo: AnyObject) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            if error == nil {
                self.showAlert(nil, text: "フォト書き込み完了")
            } else {
                self.showAlert(nil, text: "フォト書き込み失敗")
            }
        }
        //保存先dir /documents
        let fileManager = NSFileManager.defaultManager()
        let dir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        
        //保存Image使用
        let fileName = "/image.jpg"
        let path = dir + fileName
        
        if fileManager.fileExistsAtPath(path){
            _imageView.image = UIImage(contentsOfFile: path)
            print ("写真保存")
        }else{
            //            ImageView.image = ""
            print ("写真なし")
        }
    }
    
    //====================
    //UIImagePickerControllerDelegate
    //====================
    //イメージピッカーのイメージ取得時に呼ばれる(3)
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        //イメージの指定
        let image = info[UIImagePickerControllerOriginalImage]
            as! UIImage
        _imageView.image = image
        
        //ビューコントローラのビューを閉じる
        picker.presentingViewController?
            .dismissViewControllerAnimated(true, completion: nil)
    }
    
    //イメージピッカーのキャンセル時に呼ばれる(3)
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        //ビューコントローラのビューを閉じる
        picker.presentingViewController?
            .dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func twitterAction(sender: AnyObject) {
        
        // SLComposeViewControllerのインスタンス化.
        // ServiceTypeをTwitterに指定.
        myComposeView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        
        // 投稿するテキストを指定.
        //myComposeView.setInitialText("Twitter Test from Swift")
        
        // 投稿する画像を指定.
        myComposeView.addImage(_imageView.image)
        
        // myComposeViewの画面遷移.
        self.presentViewController(myComposeView, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

