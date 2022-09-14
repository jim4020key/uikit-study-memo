//
//  JoinVC.swift
//  uikit-study
//
//  Created by kimjimin on 2022/09/14.
//

import UIKit
import Alamofire

class JoinVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func submit(_ sender: Any) {
    }
    
    var fieldAccount: UITextField!
    var fieldPassword: UITextField!
    var fieldName: UITextField!
    
    override func viewDidLoad() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.profile.layer.cornerRadius = self.profile.frame.width / 2
        self.profile.layer.masksToBounds = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tappedProfile(_:)))
        self.profile.addGestureRecognizer(gesture)
    }
    
    @objc func tappedProfile(_ sender: Any) {
        let message = "프로필 이미지를 읽어올 곳을 선택하세요"
        let sheet = UIAlertController(title: message, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        sheet.addAction(UIAlertAction(title: "저장된 앨범", style: .default) {(_) in
            selectLibrary(src: .savedPhotosAlbum)
        })
        sheet.addAction(UIAlertAction(title: "포토 라이브러리", style: .default) {(_) in
            selectLibrary(src: .photoLibrary)
        })
        sheet.addAction(UIAlertAction(title: "카메라", style: .default) {(_) in
            selectLibrary(src: .camera)
        })
        self.present(sheet, animated: false)
        
        func selectLibrary(src: UIImagePickerController.SourceType) {
            if UIImagePickerController.isSourceTypeAvailable(src) {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = true
                
                self.present(picker, animated: false)
            } else {
                self.alert("사용할 수 없는 타입입니다")
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let rawVal = UIImagePickerController.InfoKey.originalImage.rawValue
        if let img = info[UIImagePickerController.InfoKey(rawValue: rawVal)] as? UIImage {
            self.profile.image = img
        }
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        let textFieldFrame = CGRect(x: 20, y: 0, width: cell.bounds.width - 20, height: 37)
        switch indexPath.row {
        case 0:
            self.fieldAccount = UITextField(frame: textFieldFrame)
            self.fieldAccount.placeholder = "계정(이메일)"
            self.fieldAccount.borderStyle = .none
            self.fieldAccount.autocapitalizationType = .none
            self.fieldAccount.font = UIFont.systemFont(ofSize: 14)
            cell.addSubview(self.fieldAccount)
        case 1:
            self.fieldPassword = UITextField(frame: textFieldFrame)
            self.fieldPassword.placeholder = "비밀번호"
            self.fieldPassword.borderStyle = .none
            self.fieldPassword.autocapitalizationType = .none
            self.fieldPassword.font = UIFont.systemFont(ofSize: 14)
            cell.addSubview(self.fieldPassword)
        case 2:
            self.fieldName = UITextField(frame: textFieldFrame)
            self.fieldName.placeholder = "이름"
            self.fieldName.borderStyle = .none
            self.fieldName.autocapitalizationType = .none
            self.fieldName.font = UIFont.systemFont(ofSize: 14)
            cell.addSubview(self.fieldName)
        default:
            ()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
