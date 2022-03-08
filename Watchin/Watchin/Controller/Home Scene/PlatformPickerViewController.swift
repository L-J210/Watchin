//
//  PlatformPickerViewController.swift
//  Watchin
//
//  Created by Archeron on 01/03/2022.
//

import UIKit

protocol PlatformPickerViewControllerDismissDelegate: AnyObject {
    func didDismiss()
}

class PlatformPickerViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var platformPickerView: UIPickerView!
    @IBOutlet weak var exitButton: UIButton!

    // MARK: - Properties

    weak var delegate: PlatformPickerViewControllerDismissDelegate?
    var show: ShowDetailFormatted?
    private let setterAspect = AspectSettings.shared
    private let watchinShowRepository = WatchinShowRepository.shared


    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setterAspect.setContainerViewAspect(for: pickerContainerView)
        setterAspect.setButtonOnWhiteBackgroundAspect(for: doneButton)
        setterAspect.setButtonOnWhiteBackgroundAspect(for: exitButton)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.presentingViewController?.viewWillAppear(true)

        if isBeingDismissed {
            delegate?.didDismiss()
        }
    }

    // MARK: - Action

    @IBAction func doneButtonTapped(_ sender: UIButton) {
        savePlatform()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func exitButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Private

    private func savePlatform() {
        guard let show = show else {
            return
        }
        let platformIndex = platformPickerView.selectedRow(inComponent: 0)
        let platform = sortedPlatformNames[platformIndex]
        watchinShowRepository.updateWatchinShowPlatform(show: show, platform: platform)
    }

}

    // MARK: - PickerView Management

extension PlatformPickerViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortedPlatformNames.count
    }


}

extension PlatformPickerViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.text = sortedPlatformNames[row]
        pickerLabel.font = UIFont(name: "Kohinoor Telugu", size: 25)
        pickerLabel.textColor = UIColor(red: 61, green: 176, blue: 239)
        pickerLabel.textAlignment = .center
        return pickerLabel
    }
}
