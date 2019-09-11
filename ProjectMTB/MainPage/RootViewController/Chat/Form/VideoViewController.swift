//
//  VideoViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/15/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import Eureka

class VideoViewController: FormViewController {

    var video:URL!
    var name:TextRow!
    var message:TextAreaRow!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        automaticallyAdjustsScrollViewInsets = false
        tableView?.contentInset = UIEdgeInsetsMake(38, 0, 0, 0)
        tableView?.backgroundColor = UIColor(hex: "#EBEBF1")
        name=TextRow(){ row in
            row.title = "File Name"
            row.placeholder = "Enter Name"
            row.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 15)
            row.add(rule: RuleRequired())
            row.validationOptions = .validatesOnDemand
        }
        .cellUpdate({ (cell, row) in
            cell.textField.font = UIFont(name: "HelveticaNeue-Light", size: 15)
            if !row.isValid{
                cell.titleLabel?.textColor = .red
                cell.titleLabel?.text = "Field Required"
            }else{
                cell.titleLabel?.textColor = .black
                cell.titleLabel?.text = "File Name"
            }
        })
        message=TextAreaRow{ row in
            row.placeholder = "Enter Message"
            row.textAreaHeight = .dynamic(initialTextViewHeight: 15)
            row.cell.textView.font = UIFont(name: "HelveticaNeue-Light", size: 15)
            }.cellUpdate({ (cell, row) in
                row.cell.textView.font = UIFont(name: "HelveticaNeue-Light", size: 15)
                cell.placeholderLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 15)
            })
        form +++ Section("Video Info")
            <<< name
            <<< message
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ChatViewController{
            let vc = segue.destination as? ChatViewController
            
            var fileSize : UInt64
            do {
                //return [FileAttributeKey : Any]
                let attr = try FileManager.default.attributesOfItem(atPath: video.path)
                fileSize = attr[FileAttributeKey.size] as! UInt64
                
                //if you convert to NSDictionary, you can get file size old way as well.
                let dict = attr as NSDictionary
                fileSize = dict.fileSize()
                vc?.video = VideoInfo(name: name.value!, message: message.value != nil ? message.value! : "", url: video, size: Double(round(Double(fileSize)/Double(10000000)*1000)/100))
                
            } catch {
                print("Error: \(error)")
            }
        }
    }

    @IBAction func closepressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendpressed(_ sender: Any) {
        name.validate()
        if name.isValid{
            performSegue(withIdentifier: "unwind", sender: self)
        }
    }
}
