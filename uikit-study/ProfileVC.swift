//
//  ProfileVC.swift
//  uikit-study
//
//  Created by kimjimin on 2022/08/22.
//

import UIKit

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let userInfo = UserInfoManager()
    let profileImage = UIImageView()
    let tableView = UITableView()
    
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.userInfo.profile = image
            self.profileImage.image = image
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
        let loginAlert = UIAlertController(title: "LOGIN", message: nil, preferredStyle: .alert)
        loginAlert.addTextField() { (tf) in
            tf.placeholder = "Your Account"
        }
        loginAlert.addTextField() { (tf) in
            tf.placeholder = "Password"
            tf.isSecureTextEntry = true
        }
        loginAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        loginAlert.addAction(UIAlertAction(title: "Login", style: .destructive) { (_) in
            let account = loginAlert.textFields?[0].text ?? ""
            let password = loginAlert.textFields?[1].text ?? ""
            
            if self.userInfo.login(account: account, password: password) {
                self.tableView.reloadData()
                self.profileImage.image = self.userInfo.profile
                self.drawButton()
            } else {
                let message = "로그인에 실패하였습니다."
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: false)
            }
        })
        self.present(loginAlert, animated: false)
    }
    
    @objc func doLogout(_ sender: Any) {
        let message = "로그아웃하시겠습니까?"
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive) { (_) in
            if self.userInfo.logout() {
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
