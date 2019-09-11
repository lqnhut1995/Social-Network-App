//
//  ChatSearchViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/20/18.
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

class ChatSearchViewController: UIViewController {

    let statusBar = UIApplication.shared.value(forKey: "statusBar") as! UIView
    @IBOutlet var uiview: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchbar: UISearchBar!
    var sections=2
    var searchData=[SearchField]()
    var searchHistory=[String]()
    var lightBox:CustomLightBox!
    var message=[Message]()
    var doneLoading=true
    var icon="Tudou"
    var dataFullfill=false
    var loadState:LoadState!
    var firstload=false
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource=self
        collectionView.delegate=self
        searchbar.delegate=self
        searchbar.setBackgroundImage(UIImage(), for: .top, barMetrics: .default)
        searchbar.backgroundColor = .clear
        searchbar.becomeFirstResponder()

        collectionView.register(UINib(nibName: "ChatCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "chatcollectionreusablecell")
        collectionView.register(UINib(nibName: "IntroductingView", bundle: nil), forCellWithReuseIdentifier: "introductingcell")
        collectionView.register(UINib(nibName: "PreviewLink", bundle: nil), forCellWithReuseIdentifier: "previewlinkcell")
        collectionView.register(UINib(nibName: "TextTypeView", bundle: nil), forCellWithReuseIdentifier: "texttypecell")
        collectionView.register(UINib(nibName: "ImageTypeView", bundle: nil), forCellWithReuseIdentifier: "imagetypecell")
        collectionView.register(UINib(nibName: "FileTypeView", bundle: nil), forCellWithReuseIdentifier: "filetypecell")
        collectionView.register(UINib(nibName: "LoadingViewCell", bundle: nil), forCellWithReuseIdentifier: "loadingcell")
        collectionView.register(UINib(nibName: "SkeletonViewCell", bundle: nil), forCellWithReuseIdentifier: "skeletoncell")
        collectionView.register(UINib(nibName: "SearchFieldsView", bundle: nil), forCellWithReuseIdentifier: "searchfieldscell")
        collectionView.register(UINib(nibName: "SearchHistoryView", bundle: nil), forCellWithReuseIdentifier: "searchhistorycell")
        
        setupSearch()
    }
    
    func setupSearch(){
        searchData.append(SearchField(fieldName: "from:", fieldDescription: "user", fieldExtraInfo: "messages"))
        searchData.append(SearchField(fieldName: "mentions:", fieldDescription: "user", fieldExtraInfo: "messages"))
        searchData.append(SearchField(fieldName: "before:", fieldDescription: "specific date", fieldExtraInfo: "messages"))
        searchData.append(SearchField(fieldName: "during:", fieldDescription: "specific date", fieldExtraInfo: "messages"))
        searchData.append(SearchField(fieldName: "after:", fieldDescription: "specific date", fieldExtraInfo: "messages"))
        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barStyle = .default
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = .white
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor(hex: "#3AD29F")
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        searchbar.layer.cornerRadius = 4
        searchbar.layer.borderColor = UIColor(hex: "#DEDEDE").cgColor
        searchbar.layer.borderWidth = 1
    }

    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func loadMessage(){
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
        link=Link.link+"/Friends/LoadMessagesFromPrivateRoom"
        param=["privateroomid":19,"page":-1]
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
}

extension ChatSearchViewController: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if sections == 2{
            return 2
        }else{
            return message.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if sections == 2{
            switch section {
            case 0:
                return searchData.count
            default:
                return searchHistory.count
            }
        }else{
            return message[section].data.count
        }

    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if sections == 2{
            if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "searchreuseview", for: indexPath) as? SearchCollectionReusableView{
                switch indexPath.section {
                case 0:
                    sectionHeader.field.text = "Search Fields"
                    sectionHeader.delete.isHidden=true
                default:
                    sectionHeader.field.text = "History"
                    sectionHeader.delete.isHidden=false
                }
                return sectionHeader
            }
        }else{
            let user=message[indexPath.section]
            if kind.isEqual(UICollectionElementKindSectionHeader) {
                if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "chatcollectionreusablecell", for: indexPath) as? ChatCollectionReusableView{
                    if indexPath.section-1 >= 0{
                        if message[indexPath.section].userid == message[indexPath.section-1].userid{
                            if !Calendar.current.isDate(Date.init(milliseconds: message[indexPath.section].uploadtime), inSameDayAs: Date.init(milliseconds: message[indexPath.section-1].uploadtime)){
                                if let image=message[indexPath.section].userimage{
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
                            if !Calendar.current.isDate(Date.init(milliseconds: message[indexPath.section].uploadtime), inSameDayAs: Date.init(milliseconds: message[indexPath.section-1].uploadtime)){
                                if let image=message[indexPath.section].userimage{
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
                                if let image=message[indexPath.section].userimage{
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
                        if let image=message[indexPath.section].userimage{
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
        }
        return UICollectionReusableView()
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if sections == 2{
            switch indexPath.section {
            case 0:
                let fieldsView=collectionView.dequeueReusableCell(withReuseIdentifier: "searchfieldscell", for: indexPath) as! SearchFieldsView
                fieldsView.fieldName.text = searchData[indexPath.row].fieldName
                fieldsView.fieldDescription.text = searchData[indexPath.row].fieldDescription
                fieldsView.fieldExtraInfo.text = searchData[indexPath.row].fieldExtraInfo
                fieldsView.index = indexPath.row
                fieldsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fieldsViewTap(sender:))))
                return fieldsView
                
            default:
                let historyView=collectionView.dequeueReusableCell(withReuseIdentifier: "searchhistorycell", for: indexPath) as! SearchHistoryView
                historyView.name.text = "user: \(searchHistory[indexPath.row])"
                return historyView   
            }
        }else{
            return dynamicContent(collectionView: collectionView, indexPath: indexPath)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if sections == 2{
            return CGSize(width: collectionView.frame.width, height: 45)
        }else{
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

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == message.count-1{
            return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if sections == 2{
            return CGSize(width: UIScreen.main.bounds.width - 10, height: 30)
        }else{
            if section-1 >= 0{
                if message[section].userid == message[section-1].userid{
                    if !Calendar.current.isDate(Date.init(milliseconds: message[section].uploadtime), inSameDayAs: Date.init(milliseconds: message[section-1].uploadtime)){
                        return CGSize(width: self.view.frame.width-20, height: 60)
                    }
                    return CGSize(width: 0, height: 16)
                }
                if !Calendar.current.isDate(Date.init(milliseconds: message[section].uploadtime), inSameDayAs: Date.init(milliseconds: message[section-1].uploadtime)){
                    return CGSize(width: self.view.frame.width-20, height: 60)
                }
                return CGSize(width: self.view.frame.width-20, height: 50)
            }
            return CGSize(width: self.view.frame.width-20, height: 50)
        }
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
    
    @objc func fieldsViewTap(sender: UITapGestureRecognizer){
        let uiview = sender.view as! SearchFieldsView
        searchbar.text = searchData[uiview.index].fieldName
    }
    
}

extension ChatSearchViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchbar.resignFirstResponder()
//        data.contains(where: {$0.range(of: searchbar.text!, options: String.CompareOptions.caseInsensitive, range: nil, locale: nil) != nil}) == true ? result = data.filter {$0.contains(searchbar.text!)} : searchbar.text == "" ? result = data : result.removeAll()
        sections=1
        collectionView.backgroundColor = .white
        loadMessage()
        self.view.endEditing(true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == ""{
            sections=2
            collectionView.backgroundColor = UIColor(hex: "EBEBF1")
            collectionView.reloadData()
        }
    }
}

extension ChatSearchViewController{
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
