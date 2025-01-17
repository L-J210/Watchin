//
//  TrackingViewController.swift
//  Watchin
//
//  Created by Archeron on 23/02/2022.
//

import UIKit

class TrackingViewController: UIViewController {

    // MARK: - Outlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tvShowPosterImageView: UIImageView!
    @IBOutlet weak var showTitleLabel: UILabel!
    @IBOutlet weak var startDateStatusLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var episodesNumberLabel: UILabel!
    @IBOutlet weak var seasonsNumberLabel: UILabel!
    @IBOutlet weak var platformLabel: UILabel!
    @IBOutlet weak var startAgainButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var platformsButton: UIButton!


    // MARK: - Properties

    var show: ShowDetailFormatted?
    var episodesBySeason: [[EpisodeFormatted]] = []
    private let aspectSetter = AspectSettings.shared
    private let watchinShowRepository = WatchinShowRepository.shared
    private let episodeDetailRepository = EpisodeDetailRepository.shared

    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let show = show else {
            return
        }
        displayShowInfos()
        episodesBySeason = episodeDetailRepository.getEpisodes(for: show)
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        aspectSetter.setButtonBasicAspect(for: startAgainButton)
        aspectSetter.setButtonBasicAspect(for: deleteButton)
        aspectSetter.setButtonBasicAspect(for: platformsButton)
    }

    // MARK: - Actions

    @IBAction func platformsButtonTapped(_ sender: UIButton) {
        goToPlatformsPicker()
    }

    @IBAction func startAgainButtonTapped(_ sender: UIButton) {
        startAgainAlert()
    }

    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        deleteAlert()
    }



    // MARK: - Private

    private func displayShowInfos() {
        guard let show = show else {
            return
        }
        aspectSetter.setImage(for: show, on: tvShowPosterImageView)
        showTitleLabel.text = show.nameFormatted
        startDateStatusLabel.text = "\(show.startDateFormatted) - \(show.statusFormatted)"
        genresLabel.text = show.genresFormatted
        countryLabel.text = show.countryFormatted
        displayEpisodesAndSeasons()
        platformLabel.text = "On : \(show.platformFormatted)"
    }

    private func displayEpisodesAndSeasons() {
        guard let show = show else {
            return
        }
        let watchedEpisodes = episodeDetailRepository.getWatchedEpisodes(for: show)
        episodesNumberLabel.text = "Episodes : \(watchedEpisodes.count)/\(show.numberOfEpisodes)"

        let watchedSeasons = episodesBySeason.filter {
            $0.allSatisfy { $0.hasBeenWatchedFormatted }
        }.count
        seasonsNumberLabel.text = "Seasons : \(watchedSeasons)/\(show.numberOfSeasons)"
    }

    private func goToPlatformsPicker() {
        guard let show = show, let platformPickerViewController = self.storyboard?.instantiateViewController(identifier: "PlatformPickerViewController") as? PlatformPickerViewController else {
            return
        }
        platformPickerViewController.show = show
        platformPickerViewController.delegate = self
        self.present(platformPickerViewController, animated: true)
    }

    private func deleteAndGoBackToHome() {
        guard let show = show else {
            return
        }
        watchinShowRepository.deleteWatchinShow(show: show)
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Alerts

    private func deleteAlert() {
        let alert = UIAlertController(title: "Warning ⚠︎", message: "\nYou are about to delete this show from your saved shows : all your episode progression will be lost.", preferredStyle: .alert)
        alert.setValue(aspectSetter.setAlertTitleAspect(for: alert), forKey: "attributedTitle")
        alert.setValue(aspectSetter.setAlertMessageAspect(for: alert), forKey: "attributedMessage")
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            self.deleteAndGoBackToHome()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    private func startAgainAlert() {
        let alert = UIAlertController(title: "Warning ⚠︎", message: "\nYou are about to delete your episode progression: are you sure you want to start this show again ?", preferredStyle: .alert)
        alert.setValue(aspectSetter.setAlertTitleAspect(for: alert), forKey: "attributedTitle")
        alert.setValue(aspectSetter.setAlertMessageAspect(for: alert), forKey: "attributedMessage")
        alert.addAction(UIAlertAction(title: "Start again", style: .destructive, handler: { action in
            guard let show = self.show else {
                return
            }
            self.episodeDetailRepository.deleteWatchedEpisodes(for: show)
            self.episodesBySeason = self.episodeDetailRepository.getEpisodes(for: show)
            self.displayEpisodesAndSeasons()
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

}

    // MARK: - Dismiss Delegate

extension TrackingViewController: PlatformPickerViewControllerDismissDelegate {
    func didDismiss() {
        guard let show = show else {
            return
        }
        self.show = watchinShowRepository.getWatchinShow(id: show.idFormatted)
        displayShowInfos()
    }
}

    // MARK: - EpisodeCell Delegate

extension TrackingViewController: EpisodeTableViewCellActionDelegate {

    func sawItButtonTapped(in cell: EpisodeTableViewCell) {
        // check if there are an indexPath and a show
        guard let indexPath = tableView.indexPath(for: cell), let show = show else {
            return
        }
        // check if not out of range
        guard episodesBySeason.count > indexPath.section,
              episodesBySeason[indexPath.section].count > indexPath.row else {
            return
        }

        let episode = episodesBySeason[indexPath.section][indexPath.row]
        episodeDetailRepository.updateEpisodeWatchedStatus(episode: episode, of: show)
        // update episode data
        episodesBySeason = episodeDetailRepository.getEpisodes(for: show)
        displayEpisodesAndSeasons()
        cell.configure(for: episodesBySeason[indexPath.section][indexPath.row])
    }
}

    // MARK: - TableView Management

extension TrackingViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return episodesBySeason.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard episodesBySeason.count > section else {
            return 0
        }
        return episodesBySeason[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EpisodeCell", for: indexPath) as? EpisodeTableViewCell else {
            return UITableViewCell()
        }

        guard episodesBySeason.count > indexPath.section,
              episodesBySeason[indexPath.section].count > indexPath.row else {
            return UITableViewCell()
        }

        let episode = episodesBySeason[indexPath.section][indexPath.row]
        cell.configure(for: episode)
        cell.delegate = self
        cell.selectionStyle = .none

        return cell
    }
}

    // MARK: - Headers Aspect

extension TrackingViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        header.backgroundColor = UIColor.white.withAlphaComponent(0.8)

        let titleLabel = UILabel(frame: CGRect(x: 20, y: 2, width: header.frame.size.width - 5, height: header.frame.size.height - 5))
        titleLabel.text = "◦ Season \(section + 1)"
        titleLabel.font = UIFont(name: "Kohinoor Telugu Medium", size: 22)
        titleLabel.textColor = UIColor.lightBlue

        header.addSubview(titleLabel)
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
}

