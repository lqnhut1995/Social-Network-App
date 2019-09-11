//
//  GroupChatViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 11/9/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import WebRTC
import SocketIO
import ObjectMapper

class GroupChatViewController: UIViewController {

    var subtopic:TopicItem!
    var iceServers:[RTCIceServer]=[RTCIceServer(urlStrings: ["turn:communicateserver.ddns.net:5349"], username: "lqnhut1995", credential: "lamquangnhut")]
    var videoClient:RTCClient?
    var captureController:RTCCapturer!
    var localCaptureView:RTCEAGLVideoView!
    var remoteCaptureView:RTCEAGLVideoView!
    var localvideoTrack:RTCVideoTrack!
    var remotevideoTrack:RTCVideoTrack!
    var offer=true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let statusBar = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor(hex: "#3AD29F")
        }
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        
        AVAudioSession.sharedInstance().requestRecordPermission { _ in}
        
        remoteCaptureView=RTCEAGLVideoView()
        localCaptureView=RTCEAGLVideoView()
        videoClient=RTCClient(iceServers: iceServers, videoCall: false)
        videoClient?.delegate=self
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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func connect(_ sender: Any) {
        videoClient?.startConnection()
        videoClient?.makeOffer()
    }
}

extension GroupChatViewController: RTCClientDelegate{
    func rtcClient(client: RTCClient, didCreateLocalCapturer capturer: RTCCameraVideoCapturer) {
        let settingsModel=RTCCapturerSettingsModel()
        self.captureController=RTCCapturer(withCapturer: capturer, settingsModel: settingsModel)
        self.captureController.startCapture()
    }
    
    func rtcClient(client: RTCClient, didGenerateIceCandidate iceCandidate: RTCIceCandidate) {
        let iceuser=IceCandidate(sdp: iceCandidate.sdp, sdpMLineIndex: iceCandidate.sdpMLineIndex, sdpMid: iceCandidate.sdpMid!)
        let json=iceuser.toJSONString(prettyPrint: true)
        sk.socket.defaultSocket.emit("exchangeIce", ["room":subtopic.subtopicid!,"data":json!])
    }
    
    func rtcClient(client: RTCClient, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) {
        DispatchQueue.main.async {
            remoteVideoTrack.add(self.remoteCaptureView)
            self.remotevideoTrack=remoteVideoTrack
        }
    }
    
    func rtcClient(client: RTCClient, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack) {
        DispatchQueue.main.async {
            localVideoTrack.add(self.localCaptureView)
            self.localvideoTrack=localVideoTrack
        }
    }
    
    func rtcClient(client: RTCClient, startCallWithSdp sdp: String) {
        let sdp=IceCandidate(sdp: sdp, sdpMLineIndex: nil, sdpMid: nil)
        let json=sdp.toJSONString(prettyPrint: true)
        if offer{
            sk.socket.defaultSocket.emit("startcalling", ["room":subtopic.subtopicid!,"data":json!])
        }else{
            sk.socket.defaultSocket.emit("startanswer", ["room":subtopic.subtopicid!,"data":json!])
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
