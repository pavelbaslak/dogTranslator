//
//  EmotionsSetUpLogic.swift
//  dogTranslator
//
//  Created by Stas Dashkevich on 10.12.22.
//

import Foundation
import UIKit
import SnapKit
import AVFAudio

extension EmotionsController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dogIconArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DogCell.id, for: indexPath) as! DogCell
        
        if selectedIndex == indexPath {
            cell.contentView.backgroundColor = UIColor(named: "cellGreen")
        } else {
            cell.contentView.backgroundColor = UIColor(named: "cellNormal")
        }
        
        if UserDefaults.standard.value(forKey: "FullAccess") as? Int == 0 {
            if UserDefaults.standard.value(forKey: dogIconArray[indexPath.row].text) as? String == "0" {
                approach = false
                if indexPath.row % 2 == 0 {
                    cell.animationView.play()
                } else {
                    
                }
            } else {
                approach = true
            }
        } else {
            approach = true
        }
        
        cell.setup(image: dogIconArray[indexPath.row].image, text: dogIconArray[indexPath.row].text, approach: approach)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedIndex = indexPath
        collectionView.reloadData()
        
        if UserDefaults.standard.value(forKey: "FullAccess") as? Int == 0 {
            if UserDefaults.standard.value(forKey: dogIconArray[indexPath.row].text) as? String == "0" {
            } else {
                DispatchQueue.main.async {
                    do {
                        try AVAudioSession.sharedInstance().setCategory(.playback)
                    } catch(let error) {
                        print(error.localizedDescription)
                    }
                    self.playStartSound("\(indexPath.row + 1)")
                }
            }
        } else {
            DispatchQueue.global().sync {
                do {
                    try AVAudioSession.sharedInstance().setCategory(.playback)
                } catch(let error) {
                    print(error.localizedDescription)
                }
                self.playStartSound("\(indexPath.row + 1)")
            }
        }
    }
    
    func setUpLogic() {
        let layout = UICollectionViewFlowLayout()

        layout.itemSize = CGSize(width: 104, height: 119)
        
        layout.minimumLineSpacing = 16
        collection = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        
        guard let collection = collection else { return }
        
        collection.register(DogCell.self, forCellWithReuseIdentifier: DogCell.id)
        collection.delegate = self
        collection.dataSource = self
        collection.showsVerticalScrollIndicator = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        
        view.addSubview(collection)
        collection.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(24)
            make.left.right.equalTo(view).inset(15)
            make.bottom.equalTo(view).offset(-80)
        }
    }
    
    @objc func openSetting() {
        let vc = SettingController()
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true)
    }
    
    @objc func openSub() {
        let vc = FirstSubscribeViewController()
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        present(vc, animated: true)
    }
    
    func playStartSound(_ soundName: String) {
            guard let path = Bundle.main.path(forResource: soundName, ofType: "mp3") else { return }
            let url = URL(fileURLWithPath: path)
        var session: AVAudioSession!
        session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(.ambient, mode: .default)
            try session.setActive(true)
        } catch {
            print(error)
        }

            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.prepareToPlay()
                player?.play()
                player?.delegate = self
                player?.volume = 1.0
            } catch _ {
            }
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
            } catch(let error) {
                print(error.localizedDescription)
        }
    }
}

extension EmotionsController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if selectedIndex == [0, 20] || selectedIndex == [0, 19] || selectedIndex == [0, 18] || selectedIndex == [0, 21] || selectedIndex == [0, 22] || selectedIndex == [0, 23] {
            return CGSize(width: 104, height: 119)
        } else {
            if selectedIndex == indexPath {
                return CGSize(width: 106, height: 123)
            } else {
                return CGSize(width: 104, height: 119)
          }
        }
      }
    }

extension EmotionsController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        selectedIndex = nil
        collection?.reloadData()
    }
}
