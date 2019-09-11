//
//  SMSearchViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/4/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import Hero

class SMSearchViewController: UIViewController{

    @IBOutlet var tableview: UITableView!
    @IBOutlet var searchbar: UISearchBar!
    let data=["MrBean#3829","likeTheFly#9233","WhereImFading#3771"]
    var result=["MrBean#3829","likeTheFly#9233","WhereImFading#3771"]
    override func viewDidLoad() {
        super.viewDidLoad()

        tableview.dataSource=self
        tableview.delegate=self
        tableview.tableFooterView = UIView()
        searchbar.delegate=self
        searchbar.setBackgroundImage(UIImage(), for: .top, barMetrics: .default)
        searchbar.backgroundColor = .clear
        searchbar.becomeFirstResponder()
        self.hero.isEnabled = true
        searchbar.hero.id = "search"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        searchbar.layer.cornerRadius = 3
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    deinit {
        print("removed")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension SMSearchViewController: UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView=UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        let label=UILabel(frame: CGRect(x: 5, y: 0, width: tableView.frame.width-40, height: 30))
        label.text = "News"
        label.font = UIFont(name: "HelveticaNeue", size: 13)
        label.textColor = UIColor(hex: "#FF5F6D")
        sectionView.backgroundColor = self.view.backgroundColor
        sectionView.addSubview(label)
        return sectionView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchcell", for: indexPath) as! SMSearchTableViewCell
        cell.imageview.image = UIImage(named: "dark_souls_art_hero_97090_320x480")
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        cell.textLabel?.text = result[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension SMSearchViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchbar.resignFirstResponder()
        data.contains(where: {$0.range(of: searchbar.text!, options: String.CompareOptions.caseInsensitive, range: nil, locale: nil) != nil}) == true ? result = data.filter {$0.contains(searchbar.text!)} : searchbar.text == "" ? result = data : result.removeAll()
        tableview.reloadData()
        self.view.endEditing(true)
    }
}
