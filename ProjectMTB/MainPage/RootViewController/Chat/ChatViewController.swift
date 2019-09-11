//
//  AdditionalViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/7/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Lightbox
import SafariServices
import AVKit
import SwiftLinkPreview
import Kingfisher
import Hero
import Alamofire
import AlamofireObjectMapper
import LinearProgressBar
import XLActionController
import DKImagePickerController
import SkeletonView

enum ChatType{
    case PrivateType
    case PublicType
    case NotificationType
}

enum LoadState{
    case firstTime
    case rest
}

class ChatViewController: UIViewController{

    var optionbtn: UIBarButtonItem!
    var subtopicName:UIBarButtonItem!
    var label=UILabel(frame: CGRect(x: 0, y: 0, width: 140, height: 30))
    var btn=UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    @IBOutlet var textviewHeightConstrant: NSLayoutConstraint!
    @IBOutlet var search: UIBarButtonItem!
    @IBOutlet var collectionViewTop: NSLayoutConstraint!
    @IBOutlet var imageCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet var imageCollectionView: UICollectionView!
    @IBOutlet var smileface: UIButton!
    @IBOutlet var extra: UIButton!
    @IBOutlet var camera: UIButton!
    @IBOutlet var send: UIButton!
    @IBOutlet var line: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var textview: UITextView!
    var lightBox:CustomLightBox!
    var images=[ImageInfo]()
    var video:VideoInfo?
    var sections=[""]
    var message=[Message]()
    var keyboardEnabled=false
    var scrollFrame:CGSize?
    var endEditTap:UITapGestureRecognizer!
    var previewLink:SwiftLinkPreview!
    var doneLoading=true
    var subtopic:TopicItem!
    var chatType:ChatType!
    var privateRoom:PrivateRoom!
    let bar=LinearProgressBar()
    var barTopConstraint:NSLayoutConstraint!
    var icon="Tudou"
    var imageRect:UIImageView!
    var progressView:UIView!
    var dataFullfill=false
    var loadState:LoadState!
    var firstload=false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        definesPresentationContext=true
        send.layer.borderColor = UIColor.lightGray.cgColor
        let barbtn=UIButton(frame: CGRect(x: 0, y: 0, width: 140, height: 30))
        label.textColor = .white
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 15)!
        barbtn.addSubview(label)
        barbtn.addTarget(self, action: #selector(channelsetting), for: .touchUpInside)
        subtopicName = UIBarButtonItem(customView: barbtn)
        navigationItem.setLeftBarButtonItems([navigationItem.leftBarButtonItem!,subtopicName], animated: false)
        
        btn.addTarget(self, action: #selector(optionbtnpressed), for: .touchUpInside)
        optionbtn = UIBarButtonItem(customView: btn)
        navigationItem.setRightBarButtonItems([optionbtn,navigationItem.rightBarButtonItem!], animated: false)
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        
        //ProgressBar
        setupProgress()
        
        //delegate
        IQKeyboardManager.shared.enable = false
        textview.delegate=self
        collectionView.delegate=self
        collectionView.dataSource=self
        collectionView.register(UINib(nibName: "ChatCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "chatcollectionreusablecell")
        collectionView.register(UINib(nibName: "IntroductingView", bundle: nil), forCellWithReuseIdentifier: "introductingcell")
        collectionView.register(UINib(nibName: "PreviewLink", bundle: nil), forCellWithReuseIdentifier: "previewlinkcell")
        collectionView.register(UINib(nibName: "TextTypeView", bundle: nil), forCellWithReuseIdentifier: "texttypecell")
        collectionView.register(UINib(nibName: "ImageTypeView", bundle: nil), forCellWithReuseIdentifier: "imagetypecell")
        collectionView.register(UINib(nibName: "FileTypeView", bundle: nil), forCellWithReuseIdentifier: "filetypecell")
        collectionView.register(UINib(nibName: "LoadingViewCell", bundle: nil), forCellWithReuseIdentifier: "loadingcell")
        collectionView.register(UINib(nibName: "SkeletonViewCell", bundle: nil), forCellWithReuseIdentifier: "skeletoncell")
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).sectionInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        imageCollectionView.dataSource=self
        imageCollectionView.delegate=self
        imageCollectionViewHeight.constant = 0
        
        //gesture
        endEditTap=UITapGestureRecognizer(target: self, action: #selector(screentouched(sender:)))
        self.collectionView.addGestureRecognizer(endEditTap)
        endEditTap.delegate=self
        
        //ImageRect For Calculate Cell Size
        imageRect=UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width-52-16, height: 300))
        imageRect.contentMode = .scaleAspectFit
        imageRect.clipsToBounds = true
        
        //imageviewer
        LightboxConfig.hideStatusBar = false
        
        //get date
        let dateFormat=DateFormatter()
        dateFormat.dateFormat = "MMMM dd,yyyy"
        let currentDate=dateFormat.string(from: Date())
        sections.append(currentDate)
        
        previewLink = SwiftLinkPreview(session: URLSession.shared,
                                   workQueue: SwiftLinkPreview.defaultWorkQueue,
                                   responseQueue: DispatchQueue.main,
                                   cache: DisabledCache.instance)
        
        //socket receive message
        sk.socket.defaultSocket.on("toroom") { (data, ack) in
            let data=data[0] as! Dictionary<String,Any>
            let items=data["items"] as! [Any]
            var itemdata=[MessageItem]()
            var messageid=0
            for dic in items{
                let dicdata=dic as! [String:Any]
                if (dicdata["datatype"] as! String).contains("image"){
                    itemdata.append(ImageItem(type: .ImageType, id: dicdata["dataid"] as! Int, localImage: nil, globalImage: dicdata["dataurl"] as? String, thumbnail: dicdata["datathumbnail"] as? String, name: dicdata["dataname"] as! String, size: CGSize(width: dicdata["width"] as! Int, height: dicdata["height"] as! Int)))
                }else if (dicdata["datatype"] as! String).contains("video"){
                    itemdata.append(VideoItem(type: .VideoType, id: dicdata["dataid"] as! Int, name: dicdata["dataname"] as! String, url: URL(string: dicdata["dataurl"] as! String)!, size: dicdata["size"] as! Double))
                }else if (dicdata["datatype"] as! String).contains("text"){
                    itemdata.append(TextItem(type: .TextType, id: dicdata["dataid"] as! Int, conversation: dicdata["message"] as! String))
                    if sk.user.userid! == data["userid"] as! Int{
                        self.previewLink.preview(dicdata["message"] as! String, dicdata, onSuccess: { (result,dic)  in
                            
                            let senddic:[String:Any]=[
                                "messageid":dic["messageid"] as! Int,
                                "mimetype":"preview",
                                "filename":"",
                                "url":result[.url] as? URL != nil ? (result[.url] as! URL).absoluteString : "",
                                "description":result[.description] as? String != nil ? result[.description] as! String : "",
                                "icon":result[.icon] as? String != nil ? result[.icon] as! String : "",
                                "image":result[.image] as? String != nil ? result[.image] as! String : "",
                                "title":result[.title] as? String != nil ? result[.title] as! String : ""
                            ]
                            //socket send message
                            sk.socket.defaultSocket.emit("updatemessage", with: [[
                                "room":data["room"] as! Int,
                                "uuid":data["uuid"] as! String,
                                "userid":data["userid"] as! Int,
                                "username":data["username"] as! String,
                                "data":senddic
                                ]])
                        }) { (_) in}
                    }
                }
                messageid=dicdata["messageid"] as! Int
            }
            switch self.chatType{
            case .PrivateType:
                self.message.append(Message(messageid: messageid, userid: data["userid"] as! Int, username: data["username"] as! String, userimage: nil, privateroomid: data["room"] as! Int, uploadtime: (Int64(data["uploadtime"] as! String))!, data: itemdata))
            default:
                self.message.append(Message(messageid: messageid, userid: data["userid"] as! Int, username: data["username"] as! String, userimage: nil, subtopicid: data["room"] as! Int, uploadtime: (Int64(data["uploadtime"] as! String))!, data: itemdata))
            }
            
            self.bar.progressValue = 100
            self.barTopConstraint.constant -= 30
            UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (_) in
                self.progressView.isHidden=true
            })
            let indexset=IndexSet(integer: self.message.count)
            let indexpath=IndexPath(item: self.message[self.message.count-1].data.count-1, section: self.message.count)
            self.collectionView.performBatchUpdates({
                self.collectionView.insertSections(indexset)
            }) { [unowned self] (_) in
                self.collectionView.scrollToItem(at: indexpath, at: UICollectionViewScrollPosition.bottom, animated: true)
            }
        }
        sk.socket.defaultSocket.on("updateroom") { [weak self](data, ack) in
            let data=data[0] as! Dictionary<String,Any>
            let items=data["items"] as! [Any]
            for dic in items{
                let dicdata=dic as! [String:Any]
                let section = self?.message.index(where: { (ms) -> Bool in
                    ms.messageid == dicdata["messageid"] as! Int
                })
                self?.message[section!].data.append(PreviewItem(type: .PreviewType, id: dicdata["dataid"] as! Int, url: URL(string: dicdata["dataurl"] as! String), title: dicdata["title"] as? String, description: dicdata["description"] as? String, image: dicdata["image"] as? String, icon: dicdata["icon"] as? String))
                self?.collectionView.performBatchUpdates({
                    self?.collectionView.insertItems(at: [IndexPath(item: self!.message[section!].data.count-1, section: section!+1)])
                }, completion: { (done) in
                    self?.collectionView.scrollToItem(at: IndexPath(item: self!.message[section!].data.count-1, section: section!+1), at: .bottom, animated: true)
                })
                
            }
        }
    }
    
    @objc func screentouched(sender: UITapGestureRecognizer){
        textview.resignFirstResponder()
        view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        IQKeyboardManager.shared.enable = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToChatView(segue:UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tochannelsetting"{
            let navView=segue.destination as! UINavigationController
            let vc=navView.viewControllers[0] as! ChannelInfoViewController
            switch chatType{
            case .PrivateType:
                vc.privateroom=privateRoom
                vc.initType(type: .DirectMessage)
            default:
                vc.subtopic = subtopic
                vc.initType(type: .ChannelSettingType)
            }
            
        }
        if segue.identifier == "voicechatsegue"{
            let vc=segue.destination as! VoiceChatViewController
            vc.privateroom=privateRoom
            switch sender as? String{
            case "voicechat":
                vc.chat="voicechat"
            default:
                vc.chat="videochat"
            }
            vc.offer=true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        line.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        send.layer.cornerRadius = 5
        send.layer.borderWidth = 0.8
    }
    
    @IBAction func sendpressed(_ sender: Any) {
        //Calculate Image Size
        var dic=[[String:Any]]()
        for index in 0..<images.count{
            if images[index].localImage != nil{
                imageRect.image = UIImage(data: images[index].localImage!)
            }
            let rect=imageRect.contentClippingRect
            images[index].size=rect.size
            dic.append(["filename":images[index].filename,"width":rect.width,"height":rect.height])
        }
        
        let text = self.textview.text == "Write Your Message" ? "" : textview.text.replacingOccurrences(of: "'", with: "\\'")
        var id=0
        switch chatType{
        case .PrivateType:
            id=self.privateRoom.privateroomid!
        default:
            id=self.subtopic.subtopicid!
        }
        if images.count > 0{
            progressView.isHidden=false
            bar.progressValue=0
            barTopConstraint.constant += 30
            UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            let mesdic:[String:Any]=[
                "type":chatType == .PrivateType ? "private" : "public",
                "roomid":id,
                "uuid":chatType == .PrivateType ? self.privateRoom.uuid! : self.subtopic.subtopicid!,
                "uploadtime":String(describing: Date().millisecondsSince1970),
                "message":text]
            Upload(downloadString: "\(Link.link)/Mainpage/uploads", image: images, video: nil, fileinfo: dic, mesdic: mesdic) { [weak self](upload,mes) in
                if let upload=upload{
                    var dicArray=[[String:Any]]()
                    if text != ""{
                        let textdic:[String:Any]=[
                            "mimetype":"text",
                            "message":mes["message"] as! String
                        ]
                        dicArray.append(textdic)
                    }
                    for item in upload{
                        let dic:[String:Any]=[
                            "url":item.filepath!,
                            "mimetype":item.mimeType!,
                            "filename":item.filename!,
                            "width":item.width!,
                            "height":item.height!,
                            "thumbnail":item.thumbnail!,
                            "size":0
                        ]
                        dicArray.append(dic)
                    }
                    //socket send message
                    sk.socket.defaultSocket.emit("message", with: [[
                        "type":mes["type"] as! String,
                        "room":mes["roomid"],
                        "uuid":mes["uuid"],
                        "userid":sk.user.userid!,
                        "uploadtime":mes["uploadtime"],
                        "username":sk.user.username!,
                        "data":dicArray
                        ]])
                    self?.images.removeAll()
                }else{
                    self?.images.removeAll()
                }
            }
        }else{
            var dicArray=[[String:Any]]()
            let textdic:[String:Any]=[
                "mimetype":"text",
                "message":text
            ]
            dicArray.append(textdic)
            sk.socket.defaultSocket.emit("message", with: [[
                "type":chatType == .PrivateType ? "private" : "public",
                "room":id,
                "uuid":chatType == .PrivateType ? self.privateRoom.uuid! : self.subtopic.subtopicid!,
                "userid":sk.user.userid!,
                "uploadtime":String(describing: Date().millisecondsSince1970),
                "username":sk.user.username!,
                "data":dicArray
                ]])
            self.images.removeAll()
        }
        
        self.imageCollectionViewHeight.constant = 0
        self.imageCollectionView.reloadData()
        if keyboardEnabled{
            textview.text = ""
        }else{
            textview.text = "Write Your Message"
            textview.textColor = .lightGray
        }
        send.backgroundColor = .white
        send.setTitleColor(.lightGray, for: .normal)
        send.layer.borderColor = UIColor.lightGray.cgColor
        send.isEnabled=false
    }
    
    @IBAction func optionpressed(_ sender: Any) {
        let picker=DKImagePickerController()
        picker.UIDelegate = CustomUIDelegate()
        picker.allowMultipleTypes=false
        picker.showsCancelButton=true
        picker.maxSelectableCount=10
        
        picker.didSelectAssets = { (assets: [DKAsset]) in
            for item in assets{
                if !item.isVideo{
                    item.fetchOriginalImageWithCompleteBlock({ [weak self](image, info) in
                        self?.imageCollectionViewHeight.constant = 125
                        self?.send.backgroundColor = UIColor(hex: "#3AD29F")
                        self?.send.setTitleColor(.white, for: .normal)
                        self?.send.layer.borderColor = UIColor(hex: "#3AD29F").cgColor
                        self?.send.isEnabled = true
                        if self?.images.count == 0{
                            self?.imageCollectionView.numberOfItems(inSection: 0)
                            let filename=((info![AnyHashable("PHImageFileURLKey")]! as! URL).path as NSString).lastPathComponent
                            self?.images.append(ImageInfo(localImage: UIImageJPEGRepresentation(image!, 0.8), globalImage: nil, thumbnail: nil, filename: filename,size: nil))
                            self?.imageCollectionView.reloadData()
                        }else{
                            self?.imageCollectionView.numberOfItems(inSection: 0)
                            let count=self?.images.count
                            let filename=((info![AnyHashable("PHImageFileURLKey")]! as! URL).path as NSString).lastPathComponent
                            self?.images.append(ImageInfo(localImage: UIImageJPEGRepresentation(image!, 0.8), globalImage: nil, thumbnail: nil, filename: filename,size: nil))
                            let indexpath=IndexPath(item: count!, section: 0)
                            self?.imageCollectionView.insertItems(at: [indexpath])
                        }
                    })
                }else{
                    item.fetchAVAssetWithCompleteBlock({ [weak self](avasset, info) in
                        let nav=UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VideoID") as! UINavigationController
                        let avurl=avasset as! AVURLAsset
                        (nav.viewControllers[0] as! VideoViewController).video = avurl.url
                        self?.present(nav, animated: true, completion: nil)
                    })
                }
            }
        }
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func searchpressed(_ sender: Any) {
        
    }

    @IBAction func unwind(segue:UIStoryboardSegue) {
        if segue.identifier == "unwind"{
            var id=0
            switch chatType{
            case .PrivateType:
                id=self.privateRoom.privateroomid!
            default:
                id=self.subtopic.subtopicid!
            }
            let mesdic:[String:Any]=[
                                     "type":chatType == .PrivateType ? "private" : "public",
                                     "roomid":id,
                                     "uuid":chatType == .PrivateType ? self.privateRoom.uuid! : self.subtopic.subtopicid!,
                                     "uploadtime":String(describing: Date().millisecondsSince1970),
                                     "videoname":video!.name+".mp4",
                                     "videosize":video!.size,
                                     "message":video!.message]
            Upload(downloadString: "\(Link.link)/Mainpage/uploadsGroup", image: nil, video: video, fileinfo: nil, mesdic: mesdic) { [weak self](upload,mes) in
                if let upload=upload{
                    var dicArray=[[String:Any]]()
                    if (mes["message"] as! String) != ""{
                        let textdic:[String:Any]=[
                            "mimetype":"text",
                            "message":mes["message"] as! String
                        ]
                        dicArray.append(textdic)
                    }
                    for item in upload{
                        let dic:[String:Any]=[
                            "url":item.filepath!,
                            "filename":mes["videoname"] as! String,
                            "mimetype":item.mimeType!,
                            "width":0,
                            "height":0,
                            "size":mes["videosize"] as! Double
                        ]
                        dicArray.append(dic)
                    }
                    //socket send message
                    sk.socket.defaultSocket.emit("message", with: [[
                        "type":mes["type"] as! String,
                        "room":mes["roomid"],
                        "uuid":mes["uuid"],
                        "userid":sk.user.userid!,
                        "uploadtime":mes["uploadtime"],
                        "username":sk.user.username!,
                        "data":dicArray
                        ]])
                    self?.video=nil
                }
            }
        }
    }
    
    @objc func channelsetting(){
        performSegue(withIdentifier: "tochannelsetting", sender: self)
    }
    
    func setupChatType(type: ChatType){
        chatType=type
        switch type {
        case .PrivateType:
            btn.setImage(UIImage(named: "Icon-App-20x20-4")?.withRenderingMode(.alwaysTemplate), for: .normal)
        default:
            btn.setImage(UIImage(named: "Icon-App-20x20-6")?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        btn.tintColor = .white
        if textview != nil {
            if chatType == .PublicType,SubViewController.isadmin != 1,!sk.permission.contains(where: {$0.settingdetailid==67}){
                textview.text = "Permission Denied"
                textview.isUserInteractionEnabled=false
                smileface.isEnabled=false
                camera.isEnabled=false
                extra.isEnabled=false
            }
            if chatType == .NotificationType{
                setupNotification()
            }else{
                textview.text = "Write Your Message"
                textview.isUserInteractionEnabled=true
                smileface.isEnabled=true
                camera.isEnabled=true
                extra.isEnabled=true
            }
        }
    }
    
    func setupNotification(){
        if SubViewController.isadmin != 1{
            textview.text = "Read Only Chat"
            textview.isUserInteractionEnabled=false
            smileface.isEnabled=false
            camera.isEnabled=false
            extra.isEnabled=false
        }else{
            textview.text = "Write Your Message"
            textview.isUserInteractionEnabled=true
            smileface.isEnabled=true
            camera.isEnabled=true
            extra.isEnabled=true
        }
    }
    
    @objc func optionbtnpressed() {
        switch chatType {
        case .PrivateType:
            present(createStandardActionSheet(), animated: true, completion: nil)
        default:
            sideMenuController?.showRightViewAnimated()
        }
    }
    
    //load Messages
    func loadMessage(roomid: Int){
        firstload=false
        dataFullfill=false
        loadState = .firstTime
        self.message.removeAll()
        if self.collectionView != nil{
            self.collectionView.reloadData()
            collectionView.prepareSkeleton { (done) in
            }
        }
        var link=""
        var param:[String:Any]!
        switch chatType{
        case .PrivateType:
            link=Link.link+"/Friends/LoadMessagesFromPrivateRoom"
            param=["privateroomid":roomid,"page":-1]
        default:
            link=Link.link+"/Friends/LoadMessagesFromSubtopic"
            param=["subtopicid":roomid,"page":-1]
        }
        LoadMessages(downloadString: link, param: param) { [weak self](mg) in
            if let mg=mg{
                if let vc=self{
                    if mg.count > 0{
                        vc.message=mg
                        vc.dataFullfill=true
                        vc.firstload=true
                        vc.collectionView.hideSkeleton()
                        vc.collectionView.reloadData()
                        vc.collectionView.setContentOffset(CGPoint(x: vc.collectionView.contentOffset.x, y: 50), animated: false)
                        vc.loadState = .rest
                        if mg[0].page! - 1 <= 0{
                            vc.dataFullfill=false
                            vc.collectionView.reloadSections(IndexSet(integer: 0))
                        }
                    }else{
                        vc.dataFullfill=false
                        vc.firstload=true
                        vc.collectionView.hideSkeleton()
                        vc.collectionView.reloadData()
                        vc.loadState = .rest
                    }
                }
            }else{
                guard let vc=self else {return}
                vc.dataFullfill=false
                vc.firstload=true
                vc.collectionView.hideSkeleton()
                vc.collectionView.reloadData()
                vc.loadState = .rest
            }
        }
    }
    
    func setupProgress(){
        progressView=UIView()
        progressView.backgroundColor = UIColor(hex: "#8e9eab")
        progressView.translatesAutoresizingMaskIntoConstraints=false
        self.view.addSubview(progressView)
        barTopConstraint = progressView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: -30)
        barTopConstraint.isActive=true
        progressView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive=true
        progressView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive=true
        progressView.heightAnchor.constraint(equalToConstant: 30).isActive=true
        
        bar.progressValue=0
        bar.barColor = UIColor(hex: "#3AD29F")
        bar.trackColor = UIColor(hex: "#EBEBF1")
        bar.barPadding = 10
        bar.trackPadding = 0
        bar.barThickness = 13
        bar.backgroundColor = .clear
        progressView.addSubview(bar)
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.topAnchor.constraint(equalTo: progressView.topAnchor, constant: 0).isActive=true
        bar.leadingAnchor.constraint(equalTo: progressView.leadingAnchor, constant: 50).isActive=true
        bar.trailingAnchor.constraint(equalTo: progressView.trailingAnchor, constant: 0).isActive=true
        bar.bottomAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 0).isActive=true
        
        let image=UIImageView()
        image.image = UIImage(named: "icons8-video-file-100")?.withRenderingMode(.alwaysTemplate)
        image.tintColor = .white
        image.contentMode = .scaleAspectFit
        progressView.addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.topAnchor.constraint(equalTo: progressView.topAnchor, constant: 2).isActive=true
        image.leadingAnchor.constraint(equalTo: progressView.leadingAnchor, constant: 0).isActive=true
        image.trailingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 0).isActive=true
        image.bottomAnchor.constraint(equalTo: progressView.bottomAnchor, constant: -2).isActive=true
        
        progressView.isHidden=true
    }
}

extension ChatViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.collectionView{
            return message.count+1
        }else{
            return 1
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0{
            return UICollectionReusableView()
        }else{
            let user=message[indexPath.section-1]
            if kind.isEqual(UICollectionElementKindSectionHeader) {
                if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "chatcollectionreusablecell", for: indexPath) as? ChatCollectionReusableView{
                    if indexPath.section-2 >= 0{
                        if message[indexPath.section-1].userid == message[indexPath.section-2].userid{
                            if !Calendar.current.isDate(Date.init(milliseconds: message[indexPath.section-1].uploadtime), inSameDayAs: Date.init(milliseconds: message[indexPath.section-2].uploadtime)){
                                if let image=message[indexPath.section-1].userimage{
                                    sectionHeader.imageview.kf.setImage(with: URL(string: image)!)
                                }else{
                                    sectionHeader.imageview.image = UIImage(named: icon)
                                }
                                sectionHeader.username.text = user.username
                                sectionHeader.messageTime.text = user.getShortDate()
                                sectionHeader.imageview.isHidden=false
                                sectionHeader.username.isHidden=false
                                sectionHeader.messageTime.isHidden=false
                                sectionHeader.time.text = user.getFullDate()
                                sectionHeader.time.isHidden=false
                                sectionHeader.timeview.isHidden=false
                            }else{
                                sectionHeader.imageview.isHidden=true
                                sectionHeader.username.isHidden=true
                                sectionHeader.messageTime.isHidden=true
                                sectionHeader.time.isHidden=true
                                sectionHeader.timeview.isHidden=true
                            }
                        }else{
                            if !Calendar.current.isDate(Date.init(milliseconds: message[indexPath.section-1].uploadtime), inSameDayAs: Date.init(milliseconds: message[indexPath.section-2].uploadtime)){
                                if let image=message[indexPath.section-1].userimage{
                                    sectionHeader.imageview.kf.setImage(with: URL(string: image)!)
                                }else{
                                    sectionHeader.imageview.image = UIImage(named: icon)
                                }
                                sectionHeader.username.text = user.username
                                sectionHeader.messageTime.text = user.getShortDate()
                                sectionHeader.imageview.isHidden=false
                                sectionHeader.username.isHidden=false
                                sectionHeader.messageTime.isHidden=false
                                sectionHeader.time.text = user.getFullDate()
                                sectionHeader.time.isHidden=false
                                sectionHeader.timeview.isHidden=false
                            }else{
                                if let image=message[indexPath.section-1].userimage{
                                    sectionHeader.imageview.kf.setImage(with: URL(string: image)!)
                                }else{
                                    sectionHeader.imageview.image = UIImage(named: icon)
                                }
                                sectionHeader.username.text = user.username
                                sectionHeader.messageTime.text = user.getShortDate()
                                sectionHeader.imageview.isHidden=false
                                sectionHeader.username.isHidden=false
                                sectionHeader.messageTime.isHidden=false
                                sectionHeader.time.isHidden=true
                                sectionHeader.timeview.isHidden=true
                            }
                        }
                    }else{
                        if let image=message[indexPath.section-1].userimage{
                            sectionHeader.imageview.kf.setImage(with: URL(string: image)!)
                        }else{
                            sectionHeader.imageview.image = UIImage(named: icon)
                        }
                        sectionHeader.username.text = user.username
                        sectionHeader.messageTime.text = user.getShortDate()
                        sectionHeader.imageview.isHidden=false
                        sectionHeader.username.isHidden=false
                        sectionHeader.messageTime.isHidden=false
                        sectionHeader.time.isHidden=true
                        sectionHeader.timeview.isHidden=true
                    }
                    return sectionHeader
                }
            }
            return UICollectionReusableView()
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView{
            if section == 0{
                return 1
            }else{
                return message[section-1].data.count
            }
        }else{
            return images.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView{
            if indexPath.section == 0{
                return !self.dataFullfill ? collectionView.dequeueReusableCell(withReuseIdentifier: "introductingcell", for: indexPath) as! IntroductionViewCell : collectionView.dequeueReusableCell(withReuseIdentifier: "loadingcell", for: indexPath) as! LoadingViewCell
            }else{
                return dynamicContent(collectionView: collectionView, indexPath: indexPath)
            }
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imagecell", for: indexPath) as! ImageChatCollectionViewCell
            cell.imageview.image = UIImage(data: images[indexPath.row].localImage!)
            cell.close.tag = indexPath.row
            cell.close.removeTarget(self, action: #selector(deleteImage(sender:)), for: .touchUpInside)
            cell.close.addTarget(self, action: #selector(deleteImage(sender:)), for: .touchUpInside)
            return cell
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if collectionView == self.collectionView{
            if loadState == .firstTime {
                return
            }
            if message.count == 0 {return}
            if indexPath.section == 0{
                if !doneLoading {return}
                guard let page = message[0].page, page-1 > 0 else {
                    return
                }
                doneLoading=false
                var link=""
                var param:[String:Any]!
                switch chatType{
                case .PrivateType:
                    link=Link.link+"/Friends/LoadMessagesFromPrivateRoom"
                    param=["privateroomid":privateRoom.privateroomid!,"page":page-1]
                default:
                    link=Link.link+"/Friends/LoadMessagesFromSubtopic"
                    param=["subtopicid":subtopic.subtopicid!,"page":page-1]
                }
                LoadMessages(downloadString: link, param: param) { [weak self](mg) in
                    if let mg=mg{
                        if let vc=self{
                            if mg.count > 0{
                                vc.message.insert(contentsOf: mg, at: 0)
                                let beforeContentSize=vc.collectionView.contentSize
                                UIView.setAnimationsEnabled(false)
                                vc.collectionView.performBatchUpdates({
                                    vc.collectionView.insertSections(IndexSet(1...mg.count))
                                }, completion: { (done) in
                                    UIView.setAnimationsEnabled(true)
                                    let afterContentSize=vc.collectionView.contentSize
                                    let afterContentOffset=vc.collectionView.contentOffset
                                    let newContentOffset=CGPoint(x: afterContentOffset.x, y: afterContentOffset.y+afterContentSize.height-beforeContentSize.height)
                                    vc.collectionView.setContentOffset(newContentOffset, animated: false)
                                    vc.doneLoading=true
                                })
                                if mg[0].page! - 1 <= 0{
                                    vc.dataFullfill=false
                                    vc.collectionView.reloadSections(IndexSet(integer: 0))
                                }
                            }else{
                                vc.doneLoading=true
                            }
                        }
                    }else{
                        guard let vc=self else{return}
                        vc.doneLoading=true
                    }
                }
            }
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == message.count{
            return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView{
            if !firstload{
                return CGSize(width: UIScreen.main.bounds.width, height: 60)
            }
            if indexPath.section == 0{
                return !self.dataFullfill ? CGSize(width: UIScreen.main.bounds.width, height: 120) : CGSize(width: UIScreen.main.bounds.width, height: 30)
            }
            
            let user=message[indexPath.section-1].data[indexPath.row]
            switch user.type {
            case .TextType:
                let detailuser=user as! TextItem
                var infosHeight:CGFloat=0
                infosHeight = detailuser.conversation.height(withConstrainedWidth: UIScreen.main.bounds.width-52-16, font: UIFont(name: "HelveticaNeue-Light", size: 14)!)
                return CGSize(width: UIScreen.main.bounds.width - 10, height: infosHeight)
            case .ImageType:
                let detailuser=user as! ImageItem
                var imagesHeight:CGFloat=0
                if detailuser.size.height > 300{
                    imagesHeight += 300
                }else{
                    imagesHeight += detailuser.size.height
                }
                return CGSize(width: UIScreen.main.bounds.width - 10, height: imagesHeight)
            case .VideoType:
                return CGSize(width: UIScreen.main.bounds.width - 10 - 100, height: CGFloat(50))
            default:
                let detailuser=user as! PreviewItem
                var previewHeight:CGFloat=0
                if let desciption=detailuser.description{
                    previewHeight=String(desciption.prefix(80)).height(withConstrainedWidth: UIScreen.main.bounds.width-52-67, font: UIFont(name: "HelveticaNeue", size: 12)!)+19
                }
                if let title=detailuser.title{
                    previewHeight += title.height(withConstrainedWidth:UIScreen.main.bounds.width-52-67, font: UIFont(name: "HelveticaNeue", size: 12)!)+30
                }
                return CGSize(width: UIScreen.main.bounds.width - 10, height: previewHeight)
            }
        }else{
            return CGSize(width: 90, height: collectionView.frame.height-5)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView == self.collectionView{
            if section == 0{
                return .zero
            }else{
                if section-2 >= 0{
                    if message[section-1].userid == message[section-2].userid{
                        if !Calendar.current.isDate(Date.init(milliseconds: message[section-1].uploadtime), inSameDayAs: Date.init(milliseconds: message[section-2].uploadtime)){
                            return CGSize(width: self.view.frame.width-20, height: 60)
                        }
                        return CGSize(width: 0, height: 16)
                    }
                    if !Calendar.current.isDate(Date.init(milliseconds: message[section-1].uploadtime), inSameDayAs: Date.init(milliseconds: message[section-2].uploadtime)){
                        return CGSize(width: self.view.frame.width-20, height: 60)
                    }
                    return CGSize(width: self.view.frame.width-20, height: 50)
                }
                return CGSize(width: self.view.frame.width-20, height: 50)
            }
        }else{
            return .zero
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView{
            
        }else{
            var lightBoxImage=[LightboxImage]()
            if self.images[indexPath.row].localImage != nil{
                lightBoxImage.append(LightboxImage(image: UIImage(data: self.images[indexPath.row].localImage!)!))
            }else{
                lightBoxImage.append(LightboxImage(imageURL: URL(string: self.images[indexPath.row].globalImage!)!))
            }
            let lightBox=LightboxController(images: lightBoxImage, startIndex: 0)
            self.present(lightBox, animated: true, completion: nil)
        }
    }
    @objc func deleteImage(sender: UIButton){
        self.images.remove(at: sender.tag)
        self.imageCollectionView.reloadData()
        if self.images.count == 0{
            self.imageCollectionViewHeight.constant = 0
            UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    func dynamicContent(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell{
        let user=message[indexPath.section-1].data[indexPath.row]
        switch user.type {
        case .TextType:
            let detailuser=user as! TextItem
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "texttypecell", for: indexPath) as! TextTypeCell
            cell.message.text = detailuser.conversation
            return cell
        case .ImageType:
            let detailuser=user as! ImageItem
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imagetypecell", for: indexPath) as! ImageTypeCell
            if let thumbnail=detailuser.thumbnail{
                cell.image.kf.setImage(with: URL(string: thumbnail), for: .normal, placeholder: UIImage(named: "tudou-logo (1)"), options: nil, progressBlock: nil) { (_, _, cache, _) in
                    cell.layer.borderWidth = 0
                }
            }else{
                cell.image.setImage(UIImage(named: "tudou-logo (1)"), for: .normal)
            }
            if detailuser.size.width > UIScreen.main.bounds.width-16-52{
                cell.image.contentMode = .scaleAspectFill
                cell.widthConstraint.constant = UIScreen.main.bounds.width-16-52
            }else{
                cell.image.contentMode = .scaleAspectFit
                cell.widthConstraint.constant = detailuser.size.width
            }
            cell.url=URL(string: detailuser.globalImage!)
            return cell
        case .VideoType:
            let detailuser=user as! VideoItem
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filetypecell", for: indexPath) as! FileTypeCell
            cell.name.text = detailuser.name
            cell.size.text = "\(detailuser.size) MB"
            cell.url=detailuser.url
            return cell
        default:
            let detailuser=user as! PreviewItem
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "previewlinkcell", for: indexPath) as! PreviewLink
            cell.title.text = detailuser.title != "" ? detailuser.title : "No Title"
            cell.link.setTitle(detailuser.url?.absoluteString, for: .normal)
            cell.newDescription.text = detailuser.description != "" ? detailuser.description : "No Description"
            if let imageURL=detailuser.image{
                cell.imageview.kf.setImage(with: URL(string: imageURL), placeholder: UIImage(named: "tudou-logo (1)"), options: nil, progressBlock: nil, completionHandler: nil)
            }
            return cell
        }
    }
}

extension ChatViewController: SkeletonCollectionViewDataSource{
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "skeletoncell"
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
}

extension ChatViewController: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textview.text == "Write Your Message"{
            textview.text=""
        }else if textview.text == ""{
            send.backgroundColor = .white
            send.setTitleColor(.lightGray, for: .normal)
            send.layer.borderColor = UIColor.lightGray.cgColor
            send.isEnabled=false
        }else if textview.text != ""{
            textview.textColor = .black
            send.backgroundColor = UIColor(hex: "#3AD29F")
            send.setTitleColor(.white, for: .normal)
            send.layer.borderColor = UIColor(hex: "#3AD29F").cgColor
            send.isEnabled=true
        }
        keyboardEnabled=true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textview.text == ""{
            textview.text="Write Your Message"
            textview.textColor = .lightGray
            send.backgroundColor = .white
            send.setTitleColor(.lightGray, for: .normal)
            send.layer.borderColor = UIColor.lightGray.cgColor
            send.isEnabled=false
        }else{
            send.backgroundColor = UIColor(hex: "#3AD29F")
            send.setTitleColor(.white, for: .normal)
            send.layer.borderColor = UIColor(hex: "#3AD29F").cgColor
            send.isEnabled=true
        }
        keyboardEnabled=false
    }
    func textViewDidChange(_ textView: UITextView) {
        if textview.text != ""{
            textview.textColor = .black
            send.backgroundColor = UIColor(hex: "#3AD29F")
            send.setTitleColor(.white, for: .normal)
            send.layer.borderColor = UIColor(hex: "#3AD29F").cgColor
            send.isEnabled=true
        }else{
            textview.textColor = .lightGray
            send.backgroundColor = .white
            send.setTitleColor(.lightGray, for: .normal)
            send.layer.borderColor = UIColor.lightGray.cgColor
            send.isEnabled=false
        }
        //dynamic height
        if textview.contentSize.height >= 200
        {
            textviewHeightConstrant.constant = 200
            textviewHeightConstrant.isActive = true
            textview.isScrollEnabled = true
        }else{
            textviewHeightConstrant.isActive = false
            textview.isScrollEnabled = false
            if textview.text == ""{
                textview.contentSize = textview.sizeThatFits(textview.frame.size)
                textviewHeightConstrant.constant = 33.5
                textviewHeightConstrant.isActive = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: Notification.Name.UIKeyboardWillShow, object: nil)
        if chatType == .PublicType,SubViewController.isadmin != 1,!sk.permission.contains(where: {$0.settingdetailid==67}){
            textview.text = "Permission Denied"
            textview.isUserInteractionEnabled=false
            smileface.isEnabled=false
            camera.isEnabled=false
            extra.isEnabled=false
        }else if chatType == .NotificationType{
            setupNotification()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillAppear(_ notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                if self.message.count > 0{
                    self.view.frame.origin.y -= keyboardSize.height
                    self.collectionViewTop.constant += keyboardSize.height
                    UIView.animate(withDuration: 0, animations: {
                        self.view.layoutIfNeeded()
                    }) { (completed) in
                        self.collectionView.scrollToItem(at: IndexPath(item: self.message[self.message.count-1].data.count - 1, section: self.message.count), at: UICollectionViewScrollPosition.bottom, animated: true)
                        self.collectionView.contentOffset.y += 20
                    }
                }else{
                    self.view.frame.origin.y -= keyboardSize.height
                    self.collectionViewTop.constant += keyboardSize.height
                    UIView.animate(withDuration: 0, animations: {
                        self.view.layoutIfNeeded()
                    }) { (completed) in
                        self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: UICollectionViewScrollPosition.bottom, animated: true)
                    }
                }
            }
        }
    }
    
    @objc func keyboardWillDisappear(_ notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
                self.collectionViewTop.constant -= keyboardSize.height
                UIView.animate(withDuration: 0, animations: {
                    self.view.layoutIfNeeded()
                }) { (completed) in
                    
                }
            }
        }
    }
}

extension ChatViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}

extension ChatViewController: UIActionSheetDelegate{
    func createStandardActionSheet() -> SkypeActionController {
        let actionsheet=SkypeActionController()
        actionsheet.addAction(Action(ActionData(title: "Voice Chat", image: UIImage(named: "icons8-add-user-group-man-man-100 (1)")!), style: .default, handler: { [weak self](action) in
            guard let vc=self else {return}
            vc.performSegue(withIdentifier: "voicechatsegue", sender: "voicechat")
        }))
        actionsheet.addAction(Action(ActionData(title: "Video Chat", image: UIImage(named: "icons8-add-user-group-man-man-100 (1)")!), style: .default, handler: { [weak self]action in
            guard let vc=self else {return}
            vc.performSegue(withIdentifier: "voicechatsegue", sender: "videochat")
        }))
        actionsheet.addAction(Action(ActionData(title: "Close DM", image: UIImage(named: "icons8-add-user-group-man-man-100 (1)")!), style: .default, handler: { action in
            // do something useful
        }))
        actionsheet.addAction(Action(ActionData(title: "Close"), style: .cancel, handler: nil))
        actionsheet.backgroundColor = UIColor(hex: "#3AD29F")
        return actionsheet
    }
    
}

extension ChatViewController{
    func LoadMessages(downloadString:String, param: [String:Any], complete: @escaping ([Message]?) -> ()){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseArray { (response: DataResponse<[Message]>) in
            switch response.result{
            case .success(_):
                if let data=response.result.value{
                    data.count > 0 ? complete(data) : complete(nil)
                }
                break
            case .failure(let error):
                if let err = error as? URLError, err.code == URLError.Code.notConnectedToInternet{
                    DispatchQueue.main.async
                        {
                            
                    }
                } else {
                    // other failures
                }
                complete(nil)
            }
        }
    }
    
    func Upload(downloadString:String,image: [ImageInfo]?,video: VideoInfo?,fileinfo: [[String:Any]]?,mesdic: [String:Any], complete: @escaping ([Upload]?,[String:Any]) -> ()){
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if let image=image,let fileinfo=fileinfo{
                for index in 0..<image.count{
                    multipartFormData.append(image[index].localImage!, withName: "files", fileName: fileinfo[index]["filename"] as! String, mimeType: "image/jpeg")
                }
            }
            if let fileinfo=fileinfo{
                do{
                    let jsondata=try JSONSerialization.data(withJSONObject: fileinfo, options: [])
                    multipartFormData.append(jsondata, withName: "fileinfo")
                }catch{}
            }
            
            if let video=video{
                multipartFormData.append(video.url, withName: "files", fileName: "video", mimeType: "video/mp4")
            }
            
        }, usingThreshold: UInt64.init(), to: downloadString, method: .post, headers: ["Content-type": "multipart/form-data"]) { [weak self](result) in
            switch result{
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    self?.bar.progressValue = CGFloat(Float(progress.completedUnitCount)/Float(progress.totalUnitCount)*90)
                })
                upload.responseArray { (response: DataResponse<[Upload]>) in
                    if let data=response.result.value{
                        data.count > 0 ? complete(data,mesdic) : complete(nil,mesdic)
                    }
                }
            case .failure(let error):
                if let err = error as? URLError, err.code == URLError.Code.notConnectedToInternet{
                    DispatchQueue.main.async
                        {
                            
                    }
                } else {
                    // other failures
                }
                complete(nil,mesdic)
            }
        }
    }
}
