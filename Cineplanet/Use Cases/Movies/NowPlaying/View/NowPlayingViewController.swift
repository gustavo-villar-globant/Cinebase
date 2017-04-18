//
//  NowPlayingViewController.swift
//  Cineplanet
//
//  Created by Gustavo Villar on 4/18/17.
//  Copyright © 2017 Globant. All rights reserved.
//

import UIKit

struct MovieCellModel {
    var title: String
}

protocol NowPlayingView: class {
    func startLoading()
    func stopLoading()
    func displayMovies(_ movieCellModels: [MovieCellModel])
    func display(_ error: Error)
}

class NowPlayingViewController: UIViewController {
    
    var presenter: NowPlayingPresenter!
    
    var movieCellModels: [MovieCellModel] = []
    let movieCellIdentifier = "MovieCell"
    
    @IBOutlet weak var tableView: UITableView!
    fileprivate weak var loadingView: UIActivityIndicatorView?

    override func viewDidLoad() {
        setupSubviews()
        presenter.onViewLoad()
    }
    
    private func setupSubviews() {
        title = "Now Playing"
        tableView.alpha = 0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: movieCellIdentifier)
    }
}

// MARK: - Now Playing View
extension NowPlayingViewController: NowPlayingView {
    
    private func setupLoadingViewIfNeeded() -> UIActivityIndicatorView {
        if let loadingView = loadingView {
            return loadingView
        } else {
            
            let loadingView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            
            loadingView.color = .gray
            loadingView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(loadingView)
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            
            self.loadingView = loadingView
            return loadingView
            
        }
    }
    
    func startLoading() {
        
        let loadingView = setupLoadingViewIfNeeded()
        loadingView.alpha = 0
        loadingView.startAnimating()
        
        UIView.animate(withDuration: 1, delay: 1, options: [], animations: { [weak loadingView] in
            loadingView?.alpha = 1
        }, completion: nil)
        
    }
    
    func stopLoading() {
        
        guard let loadingView = loadingView else { return }
        self.loadingView = nil
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState], animations: { [weak loadingView] in
            loadingView?.alpha = 0
        }, completion: { (completed) in
            loadingView.removeFromSuperview()
        })
        
    }
    
    func displayMovies(_ movieCellModels: [MovieCellModel]) {
        self.movieCellModels = movieCellModels
        tableView.reloadData()
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.tableView.alpha = 1
        }
    }
    
    func display(_ error: Error) {
        
    }
    
}
