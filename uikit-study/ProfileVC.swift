//
//  ProfileVC.swift
//  uikit-study
//
//  Created by kimjimin on 2022/08/22.
//

import UIKit
import Alamofire
import LocalAuthentication

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let userInfo = UserInfoManager()
    let profileImage = UIImageView()
    let tableView = UITableView()
    var isCalling = false
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        self.navigationItem.title = "프로필"
        let backButton = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(close(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        
        let image = self.userInfo.profile
        self.profileImage.image = image
        self.profileImage.frame.size = CGSize(width: 100, height: 100)
        self.profileImage.center = CGPoint(x: self.view.frame.width / 2, y: 270)
        self.profileImage.layer.cornerRadius = self.profileImage.frame.width / 2
        self.profileImage.layer.borderWidth = 0
        self.profileImage.layer.masksToBounds = true
        self.view.addSubview(self.profileImage)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(profile(_:)))
        self.profileImage.addGestureRecognizer(tap)
        self.profileImage.isUserInteractionEnabled = true
        
        self.tableView.frame = CGRect(x: 0, y: self.profileImage.frame.origin.y + self.profileImage.frame.size.height + 20, width: self.view.frame.width, height: 100)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.view.addSubview(self.tableView)
        
        let bg = UIImage(named: "profile-bg")
        let bgImage = UIImageView(image: bg)
        bgImage.frame.size = CGSize(width: bgImage.frame.size.width, height: bgImage.frame.size.height)
        bgImage.center = CGPoint(x: self.view.frame.width / 2, y: 40)
        bgImage.layer.cornerRadius = bgImage.frame.size.width / 2
        bgImage.layer.borderWidth = 0
        bgImage.layer.masksToBounds = true
        self.view.addSubview(bgImage)
        self.view.bringSubviewToFront(self.tableView)
        self.view.bringSubviewToFront(self.profileImage)
        
        self.drawButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tokenValidate()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.indicatorView.startAnimating()
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.userInfo.newProfile(image, success: {
                self.indicatorView.stopAnimating()
                self.profileImage.image = image
            }, fail: { msg in
                self.indicatorView.stopAnimating()
                self.alert(msg)
            })
        }
        picker.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.accessoryType = .disclosureIndicator
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "이름"
            cell.detailTextLabel?.text = self.userInfo.name ?? "Login please"
        case 1:
            cell.textLabel?.text = "계정"
            cell.detailTextLabel?.text = self.userInfo.account ?? "Login please"
        default:
            ()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.userInfo.isLogin == false {
            self.doLogin(self.tableView)
        }
    }
    
    func imagePicker(_ source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true)
    }
    
    func drawButton() {
        let view = UIView()
        view.frame.size.width = self.view.frame.width
        view.frame.size.height = 43.5
        view.frame.origin.x = 0
        view.frame.origin.y = self.tableView.frame.origin.y + self.tableView.frame.height
        view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        self.view.addSubview(view)
        
        let button = UIButton(type: .system)
        button.frame.size.width = 100
        button.frame.size.height = 30
        button.center.x = view.frame.size.width / 2
        button.center.y = view.frame.size.height / 2
        
        if self.userInfo.isLogin == true {
            button.setTitle("로그아웃", for: .normal)
            button.addTarget(self, action: #selector(doLogout(_:)), for: .touchUpInside)
        } else {
            button.setTitle("로그인", for: .normal)
            button.addTarget(self, action: #selector(doLogin(_:)), for: .touchUpInside)
        }
        view.addSubview(button)
        self.view.bringSubviewToFront(self.indicatorView)
    }
    
    @objc func profile(_ sender: UIButton) {
        guard self.userInfo.account != nil else {
            self.doLogin(self)
            return
        }
        
        let alert = UIAlertController(title: nil, message: "사진을 가져올 곳을 선택해 주세요", preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "카메라", style: .default) { (_) in
                self.imagePicker(.camera)
            })
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            alert.addAction(UIAlertAction(title: "저장된 앨범", style: .default) { (_) in
                self.imagePicker(.savedPhotosAlbum)
            })
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "포토 라이브러리", style: .default) { (_) in
                self.imagePicker(.photoLibrary)
            })
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    @objc func close(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @objc func doLogin(_ sender: Any) {
        if self.isCalling == true {
            self.alert("응답을 기다리는 중입니다\n잠시만 기다려 주세요")
            return
        } else {
            self.isCalling = true
        }
        
        let loginAlert = UIAlertController(title: "LOGIN", message: nil, preferredStyle: .alert)
        loginAlert.addTextField() { (tf) in
            tf.placeholder = "Your Account"
        }
        loginAlert.addTextField() { (tf) in
            tf.placeholder = "Password"
            tf.isSecureTextEntry = true
        }
        loginAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.isCalling = false
        })
        loginAlert.addAction(UIAlertAction(title: "Login", style: .destructive) { (_) in
            self.indicatorView.startAnimating()
            self.isCalling = false
            
            let account = loginAlert.textFields?[0].text ?? ""
            let password = loginAlert.textFields?[1].text ?? ""
            
            self.userInfo.login(account: account, password: password, success: {
                self.indicatorView.stopAnimating()
                self.tableView.reloadData()
                self.profileImage.image = self.userInfo.profile
                self.drawButton()
                
                let sync = DataSync()
                DispatchQueue.global(qos: .background).async {
                    sync.downloadBackupData()
                }
                DispatchQueue.global(qos: .background).async {
                    sync.uploadData()
                }
            }, fail: { message in
                self.indicatorView.stopAnimating()
                self.isCalling = false
                self.alert(message)
            })
        })
        self.present(loginAlert, animated: false)
    }
    
    @objc func doLogout(_ sender: Any) {
        let message = "로그아웃하시겠습니까?"
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive) { (_) in
            self.indicatorView.startAnimating()
            
            self.userInfo.logout() {
                self.indicatorView.stopAnimating()
                self.tableView.reloadData()
                self.profileImage.image = self.userInfo.profile
                self.drawButton()
            }
        })
        self.present(alert, animated: false)
    }
    
    @IBAction func backProfileVC(_ seg: UIStoryboardSegue) {
    }
}

extension ProfileVC {
    func tokenValidate() {
        URLCache.shared.removeAllCachedResponses()
        
        let tk = TokenUtils()
        guard let header = tk.getAuthorizationHeader() else { return }
        
        self.indicatorView.startAnimating()
        
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/tokenValidate"
        let validate = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: header)
        validate.responseJSON { res in
            self.indicatorView.stopAnimating()
            
            let responseBody = try! res.result.get()
            print(responseBody)
            guard let jsonObject = responseBody as? NSDictionary else {
                self.alert("잘못된 응답입니다")
                return
            }
            
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode != 0 {
                self.touchID()
            }
        }
    }
    
    func touchID() {
        let context = LAContext()
        var error: NSError?
        let message = "인증이 필요합니다"
        let deviceAuth = LAPolicy.deviceOwnerAuthenticationWithBiometrics
        
        if context.canEvaluatePolicy(deviceAuth, error: &error) {
            context.evaluatePolicy(deviceAuth, localizedReason: message) { (success, error) in
                if success {
                    self.refresh()
                } else {
                    print((error?.localizedDescription)!)
                    switch (error!._code) {
                    case LAError.systemCancel.rawValue:
                        self.alert("시스템에 의해 인증이 취소되었습니다")
                    case LAError.userCancel.rawValue:
                        self.alert("사용자에 의해 인증이 취소되었습니다") {
                            self.commonLogout(true)
                        }
                    case LAError.userFallback.rawValue:
                        OperationQueue.main.addOperation() {
                            self.commonLogout(true)
                        }
                    default:
                        OperationQueue.main.addOperation() {
                            self.commonLogout(true)
                        }
                    }
                }
            }
        } else {
            print(error!.localizedDescription)
            switch (error!.code) {
            case LAError.biometryNotEnrolled.rawValue:
                print("터치 아이디가 등록되어 있지 않습니다")
            case LAError.passcodeNotSet.rawValue:
                print("패스 코드가 설정되어 있지 않습니다")
            default:
                print("터치 아이디를 사용할 수 없습니다")
            }
        }
    }
    
    func refresh() {
        self.indicatorView.startAnimating()
        
        let tk = TokenUtils()
        let header = tk.getAuthorizationHeader()
        
        let refreshToken = tk.load("kr.co.rubypaper.MyMemory", account: "refreshToken")
        let param: Parameters = ["refresh_token": refreshToken!]
        
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/refresh"
        let refresh = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header)
        refresh.responseJSON { res in
            self.indicatorView.stopAnimating()
            
            guard let jsonObject = try! res.result.get() as? NSDictionary else {
                self.alert("잘못된 응답입니다")
                return
            }
            
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 {
                let accessToken = jsonObject["access_token"] as! String
                tk.save("kr.co.rubypaper.MyMemory", account: "accessToken", value: accessToken)
            } else {
                self.alert("인증이 만료되었으므로 다시 로그인해야 합니다") {
                    OperationQueue.main.addOperation() {
                        self.commonLogout(true)
                    }
                }
            }
        }
    }
    
    func commonLogout(_ isLogin: Bool = false) {
        let userInfo = UserInfoManager()
        userInfo.deviceLogout()
        
        self.tableView.reloadData()
        self.profileImage.image = userInfo.profile
        self.drawButton()
        
        if isLogin {
            self.doLogin(self)
        }
    }
}
