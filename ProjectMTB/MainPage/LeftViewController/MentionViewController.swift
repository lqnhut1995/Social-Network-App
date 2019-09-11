//
//  MentionViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 11/11/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
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

class MentionViewController: UIViewController {

    @IBOutlet var collectionview:UICollectionView!
    var lightBox:CustomLightBox!
    var message=[Message]()
    var doneLoading=true
    var icon="Tudou"
    var dataFullfill=false
    var loadState:LoadState!
    var firstload=false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionview.delegate=self
        collectionview.dataSource=self
        collectionview.register(UINib(nibName: "ChatCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "chatcollectionreusablecell")
        collectionview.register(UINib(nibName: "IntroductingView", bundle: nil), forCellWithReuseIdentifier: "introductingcell")
        collectionview.register(UINib(nibName: "PreviewLink", bundle: nil), forCellWithReuseIdentifier: "previewlinkcell")
        collectionview.register(UINib(nibName: "TextTypeView", bundle: nil), forCellWithReuseIdentifier: "texttypecell")
        collectionview.register(UINib(nibName: "ImageTypeView", bundle: nil), forCellWithReuseIdentifier: "imagetypecell")
        collectionview.register(UINib(nibName: "FileTypeView", bundle: nil), forCellWithReuseIdentifier: "filetypecell")
        collectionview.register(UINib(nibName: "LoadingViewCell", bundle: nil), forCellWithReuseIdentifier: "loadingcell")
        collectionview.register(UINib(nibName: "SkeletonViewCell", bundle: nil), forCellWithReuseIdentifier: "skeletoncell")
        collectionview.prepareSkeleton { (done) in
        }
        (collectionview.collectionViewLayout as! UICollectionViewFlowLayout).sectionInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        loadMessage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadMessage(roomid: Int = 19){
        firstload=false
        dataFullfill=false
        loadState = .firstTime
        self.message.removeAll()
        if self.collectionview != nil{
            self.collectionview.reloadData()
            collectionview.prepareSkeleton { (done) in
            }
        }
        var link=""
        var param:[String:Any]!
        link=Link.link+"/Friends/LoadMessagesFromPrivateRoom"
        param=["privateroomid":roomid,"page":-1]
        LoadMessages(downloadString: link, param: param) { [weak self](mg) in
            if let mg=mg{
                if let vc=self{
                    if mg.count > 0{
                        vc.message=mg
                        vc.dataFullfill=true
                        vc.firstload=true
                        vc.collectionview.hideSkeleton()
                        vc.collectionview.reloadData()
                        vc.collectionview.scrollToItem(at: IndexPath(item: vc.message[vc.message.count-1].data.count-1, section: vc.message.count-1), at: .bottom, animated: false)
                        vc.loadState = .rest
                    }else{
                        vc.dataFullfill=false
                        vc.firstload=true
                        vc.collectionview.hideSkeleton()
                        vc.collectionview.reloadData()
                        vc.collectionview.scrollToItem(at: IndexPath(item: vc.message[vc.message.count-1].data.count-1, section: vc.message.count-1), at: .bottom, animated: false)
                        vc.loadState = .rest
                    }
                }
            }else{
                guard let vc=self else {return}
                vc.dataFullfill=false
                vc.firstload=true
                vc.collectionview.hideSkeleton()
                vc.collectionview.reloadData()
                vc.collectionview.scrollToItem(at: IndexPath(item: vc.message[vc.message.count-1].data.count-1, section: vc.message.count-1), at: .bottom, animated: false)
                vc.loadState = .rest
            }
        }
    }

}

extension MentionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return message.count
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let user=message[indexPath.section]
        if kind.isEqual(UICollectionElementKindSectionHeader) {
            if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "chatcollectionreusablecell", for: indexPath) as? ChatCollectionReusableView{
                sectionHeader.imageview.image = UIImage(named: icon)
                sectionHeader.username.text = user.username
                sectionHeader.messageTime.text = user.getDateDetail()
                sectionHeader.imageview.isHidden=false
                sectionHeader.username.isHidden=false
                sectionHeader.messageTime.isHidden=false
                sectionHeader.time.isHidden=true
                sectionHeader.timeview.isHidden=false
                sectionHeader.channel.isHidden=false
                sectionHeader.classname.isHidden=false
                sectionHeader.group.isHidden=false
                sectionHeader.channel.text = "Fuctioning Motion"
                sectionHeader.classname.text = "Normalize"
                sectionHeader.group.text = "King Meat"
                return sectionHeader
            }
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return message[section].data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return dynamicContent(collectionView: collectionView, indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
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
            var param:[String:Any]!
            param=["privateroomid":19,"page":page-1]
            LoadMessages(downloadString: Link.link+"/Friends/LoadMessagesFromPrivateRoom", param: param) { [weak self](mg) in
                if let mg=mg{
                    if let vc=self{
                        if mg.count > 0{
                            vc.message.insert(contentsOf: mg, at: 0)
                            let beforeContentSize=vc.collectionview.contentSize
                            UIView.setAnimationsEnabled(false)
                            vc.collectionview.performBatchUpdates({
                                vc.collectionview.insertSections(IndexSet(1...mg.count))
                            }, completion: { (done) in
                                UIView.setAnimationsEnabled(true)
                                let afterContentSize=vc.collectionview.contentSize
                                let afterContentOffset=vc.collectionview.contentOffset
                                let newContentOffset=CGPoint(x: afterContentOffset.x, y: afterContentOffset.y+afterContentSize.height-beforeContentSize.height)
                                vc.collectionview.setContentOffset(newContentOffset, animated: false)
                                vc.doneLoading=true
                            })
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == message.count-1{
            return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if !firstload{
            return CGSize(width: UIScreen.main.bounds.width, height: 60)
        }
        
        let user=message[indexPath.section].data[indexPath.row]
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
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width-20, height: 70)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }

    func dynamicContent(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell{
        let user=message[indexPath.section].data[indexPath.row]
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

extension MentionViewController{
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
}
