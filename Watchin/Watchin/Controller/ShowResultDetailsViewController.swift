//
//  ShowResultDetailsViewController.swift
//  Watchin
//
//  Created by Archeron on 11/02/2022.
//

import UIKit

class ShowResultDetailsViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var tvShowPosterImageView: UIImageView!
    @IBOutlet weak var showTitleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var seasonCountLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var addToYourShowsButton: UIButton!
    @IBOutlet weak var addToWatchinLaterButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var seeMoreButton: UIButton!

    // MARK: - Properties

    var tvShow: ShowDetailFormatted?
    private let repository = WatchinShowRepository.shared

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setButtonAspect(for: addToYourShowsButton)
        setButtonAspect(for: addToWatchinLaterButton)
        setButtonAspect(for: seeMoreButton)
        configureAddToYourShowsButton()

        displayShowDetails()
    }

    // MARK: - Actions

    @IBAction func addToYourShowsButtonTapped(_ sender: UIButton) {
        saveShowToYourShows()
        configureAddToYourShowsButton()
    }

    @IBAction func addToWatchinLaterButtonTapped(_ sender: UIButton) {
    }

    @IBAction func seeMoreButtonTapped(_ sender: UIButton) {
        goToWebsite()
    }

    // MARK: - Private

    private func displayShowDetails() {
        guard let tvShow = tvShow else {
            return
        }

        setImage()
        showTitleLabel.text = tvShow.nameFormatted
        yearLabel.text = tvShow.startDateFormatted
        genresLabel.text = tvShow.genresFormatted
        countryLabel.text = tvShow.countryFormatted
        seasonCountLabel.text = tvShow.numberOfSeasons
        statusLabel.text = tvShow.statusFormatted
        descriptionLabel.text = tvShow.descriptionFormatted
    }

    private func setImage() {
        guard let tvShow = tvShow else {
            return
        }
        if let imageUrl = URL(string: tvShow.imageStringUrlFormatted) {
            tvShowPosterImageView.af.setImage(withURL: imageUrl, placeholderImage: UIImage(named: "watchinIcon"))
        } else {
            tvShowPosterImageView.image = UIImage(named: "watchinIcon")
        }
    }

    private func saveShowToYourShows() {
        guard let show = tvShow else {
            return
        }
        let success = repository.saveWatchinShow(show: show)
        if success {
            successAlert(message: "Added to your shows ! 📺")
        } else {
            errorAlert(message: "We were unable to add this show to your show")
        }
    }

    private func goToWebsite() {
        guard let tvShow = tvShow else {
            return
        }
        guard let url = URL(string: tvShow.descriptionSourceFormatted) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    // MARK: - Alerts

    private func successAlert(message: String) {
        let alert = UIAlertController(title: "✅", message: message, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
           self.dismiss(animated: true)
          }
    }

    private func errorAlert(message: String) {
        let alert = UIAlertController(title: "❌", message: message, preferredStyle: .alert)
        let actionAlert = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(actionAlert)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - UI Aspect

    private func configureAddToYourShowsButton() {
        guard let show = tvShow else {
            return
        }

        let isSavedToYourShows = repository.isAlreadySaved(show: show)
        let title = isSavedToYourShows ? "Added to your shows" : "Add to your shows"
        let color = isSavedToYourShows ? UIColor(red: 61, green: 176, blue: 239) : UIColor.white
        let backgroundColor = isSavedToYourShows ? UIColor.white : UIColor.clear
        let clickableState = isSavedToYourShows ? false : true

        // se renseigner sur attributedStrings
        addToYourShowsButton.setTitle(title, for: .normal)
        addToYourShowsButton.setTitleColor(color, for: .normal)
        addToYourShowsButton.tintColor = color
        addToYourShowsButton.backgroundColor = backgroundColor
        addToYourShowsButton.isEnabled = clickableState
    }

    private func setButtonAspect(for button: UIButton) {
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 10
    }

}
