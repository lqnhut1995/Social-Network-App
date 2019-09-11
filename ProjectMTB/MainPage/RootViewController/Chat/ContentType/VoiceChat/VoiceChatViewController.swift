//
//  VoiceChatViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 10/27/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import WebRTC
import SocketIO
import ObjectMapper

class VoiceChatViewController: UIViewController,UIGestureRecognizerDelegate {

    @IBOutlet var callbtn: UIButton!
    @IBOutlet var imageview: UIImageView!
    let statusBar = UIApplication.shared.value(forKey: "statusBar") as! UIView
    var privateroom:PrivateRoom!
    var iceServers:[RTCIceServer]=[RTCIceServer(urlStrings: ["turn:communicateserver.ddns.net:5349"], username: "lqnhut1995", credential: "lamquangnhut")]
    var videoClient:RTCClient?
    var captureController:RTCCapturer!
    var localCaptureView:RTCEAGLVideoView!
    var remoteCaptureView:RTCEAGLVideoView!
    var localvideoTrack:RTCVideoTrack!
    var remotevideoTrack:RTCVideoTrack!
    var offer=false
    var data:[Any]!
    var chat:String!
    var changecameraposition=0
    override func viewDidLoad() {
        super.viewDidLoad()

        AVAudioSession.sharedInstance().requestRecordPermission { _ in}
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = UIScreen.main.bounds
        imageview.addSubview(blurView)
        
        remoteCaptureView=RTCEAGLVideoView(frame: CGRect(x: 20, y: 100, width: 90, height: 100))
        remoteCaptureView.backgroundColor = .black
        let tap=UITapGestureRecognizer(target: self, action: #selector(videotap))
        tap.delegate=self
        remoteCaptureView.addGestureRecognizer(tap)
        localCaptureView=RTCEAGLVideoView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        if chat == "voicechat"{
            remoteCaptureView.isHidden=true
            localCaptureView.isHidden=true
            videoClient=RTCClient(iceServers: iceServers, videoCall: false)
            videoClient?.delegate=self
        }else{
            remoteCaptureView.isHidden=false
            localCaptureView.isHidden=false
            videoClient=RTCClient(iceServers: iceServers, videoCall: true)
            videoClient?.delegate=self
        }
        remoteCaptureView.contentMode = .scaleAspectFit
        localCaptureView.contentMode = .scaleAspectFit
        imageview.addSubview(localCaptureView)
        imageview.bringSubview(toFront: localCaptureView)
        view.addSubview(remoteCaptureView)
        view.bringSubview(toFront: remoteCaptureView)
        sk.socket.defaultSocket.on("sendAnswer") { (data, ack) in
            let data=data[0] as! Dictionary<String,Any>
            let object=IceCandidate(JSONString: data["data"] as! String)
            self.videoClient?.handleAnswerReceived(withRemoteSDP: object?.sdp)
        }
        sk.socket.defaultSocket.on("sendIceCandidate") { (data, ack) in
            let data=data[0] as! Dictionary<String,Any>
            let object=IceCandidate(JSONString: data["data"] as! String)
            self.videoClient?.addIceCandidate(iceCandidate: RTCIceCandidate(sdp: object!.sdp!, sdpMLineIndex: object!.sdpMLineIndex!, sdpMid: object!.sdpMid!))
        }
        
        sk.socket.defaultSocket.on("createAnswer") { (data, ack) in
            self.data=data
            var data1=data[0] as! Dictionary<String,Any>
            let object=PrivateRoom(JSONString: data1["privateroom"] as! String)
            self.privateroom=object
            self.createAnswer(data: data)
        }
        
        if offer{
            sk.socket.defaultSocket.emit("notifystate", with: [["room":privateroom.uuid!,"type":chat]])
        }
        
        if data != nil{
            callbtn.setImage(UIImage(named: "telephone-symbol-button-green"), for: .normal)
        }
        
    }
    
    func createAnswer(data: [Any]){
        self.videoClient?.disconnect()
        self.videoClient?.startConnection()
        var data=data[0] as! Dictionary<String,Any>
        let object=IceCandidate(JSONString: data["data"] as! String)
        self.videoClient?.createAnswerForOfferReceived(withRemoteSDP: object?.sdp)
        self.data=nil
    }
    
    @objc func videotap(){
        if changecameraposition == 0{
            changecameraposition=1
            if remotevideoTrack != nil{
                remotevideoTrack.remove(self.remoteCaptureView)
                remotevideoTrack.add(self.localCaptureView)
            }
            localvideoTrack.remove(self.localCaptureView)
            localvideoTrack.add(self.remoteCaptureView)
        }else{
            changecameraposition=0
            if remotevideoTrack != nil{
                remotevideoTrack.remove(self.localCaptureView)
                remotevideoTrack.add(self.remoteCaptureView)
            }
            localvideoTrack.remove(self.remoteCaptureView)
            localvideoTrack.add(self.localCaptureView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = .clear
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor(hex: "#3AD29F")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    @IBAction func exit(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func stopcalling(_ sender: Any) {
        if data != nil{
            callbtn.setImage(UIImage(named: "telephone-symbol-button"), for: .normal)
            self.videoClient?.startConnection()
            self.videoClient?.makeOffer()
        }else{
            videoClient?.disconnect()
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func microphone(_ sender: Any) {
        
    }
    
    @IBAction func camera(_ sender: Any) {
        if let bool=videoClient?.isVideoCall,!bool{
            localCaptureView.isHidden=false
            remoteCaptureView.isHidden=false
            videoClient=RTCClient(iceServers: iceServers, videoCall: true)
        }else{
            localCaptureView.isHidden=true
            remoteCaptureView.isHidden=true
            videoClient=RTCClient(iceServers: iceServers, videoCall: false)
        }
        videoClient?.delegate=self
        videoClient?.startConnection()
        videoClient?.makeOffer()
    }
}

extension VoiceChatViewController: RTCClientDelegate{
    func rtcClient(client: RTCClient, didCreateLocalCapturer capturer: RTCCameraVideoCapturer) {
        let settingsModel=RTCCapturerSettingsModel()
        self.captureController=RTCCapturer(withCapturer: capturer, settingsModel: settingsModel)
        self.captureController.startCapture()
    }
    
    func rtcClient(client: RTCClient, didGenerateIceCandidate iceCandidate: RTCIceCandidate) {
        let iceuser=IceCandidate(sdp: iceCandidate.sdp, sdpMLineIndex: iceCandidate.sdpMLineIndex, sdpMid: iceCandidate.sdpMid!)
        let json=iceuser.toJSONString(prettyPrint: true)
        sk.socket.defaultSocket.emit("exchangeIce", ["room":privateroom.uuid!,"data":json!])
    }
    
    func rtcClient(client: RTCClient, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) {
        DispatchQueue.main.async {
            switch self.changecameraposition{
            case 0:
                remoteVideoTrack.add(self.remoteCaptureView)
                self.remotevideoTrack=remoteVideoTrack
            default:
                remoteVideoTrack.add(self.localCaptureView)
                self.localvideoTrack=remoteVideoTrack
            }
        }
    }
    
    func rtcClient(client: RTCClient, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack) {
        DispatchQueue.main.async {
            switch self.changecameraposition{
            case 0:
                localVideoTrack.add(self.localCaptureView)
                self.localvideoTrack=localVideoTrack
            default:
                localVideoTrack.add(self.remoteCaptureView)
                self.remotevideoTrack=localVideoTrack
            }
        }
    }
    
    func rtcClient(client: RTCClient, startCallWithSdp sdp: String) {
        let sdp=IceCandidate(sdp: sdp, sdpMLineIndex: nil, sdpMid: nil)
        let json=sdp.toJSONString(prettyPrint: true)
        if offer{
            sk.socket.defaultSocket.emit("startcalling", ["room":privateroom.uuid!,"data":json!,"privateroom":privateroom.toJSONString(prettyPrint: true)])
        }else{
            sk.socket.defaultSocket.emit("startanswer", ["room":privateroom.uuid!,"data":json!,"privateroom":privateroom.toJSONString(prettyPrint: true)])
        }
    }
    
    func rtcClient(client: RTCClient, didChangeState state: RTCClientState) {
        if state == RTCClientState.disconnected{

        }
        if state == RTCClientState.connected{
            
        }
    }
    
    func rtcClient(client: RTCClient, didReceiveError error: Error) {
        print("connect interrupted")
    }
}
