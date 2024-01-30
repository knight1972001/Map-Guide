//
//  MovieViewController.swift
//  Assignment3_API
//
//  Created by Đỗ Mai Khánh Nhi on 24/03/2023.
//

import UIKit

class MovieViewController: UIViewController {

    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var progressBarField: UIProgressView!
    @IBOutlet weak var imageField: UIImageView!
    @IBOutlet weak var awardLabel: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    
    @IBOutlet weak var ratedLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    var imdbID = ""
    var movieDetail: MovieDetail?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        titleLabel.text = imdbID
        
        
        getMovieDetail(imdbId: imdbID){ result in
            self.movieDetail = result
            print(self.movieDetail?.title)
            DispatchQueue.main.async {
                self.titleLabel.text = self.movieDetail?.title
                self.releaseDateLabel.text = self.movieDetail?.released
                self.ratedLabel.text = self.movieDetail?.rated
                self.runtimeLabel.text = self.movieDetail?.runtime
                self.genreLabel.text = self.movieDetail?.genre
                self.directorLabel.text = self.movieDetail?.director
                self.awardLabel.text = self.movieDetail?.award
                self.progressBarField.progress = Float((self.movieDetail?.imdbRating ?? 0)/10)
                if let url = URL(string: self.movieDetail!.imgPosterURL) {
                    do {
                        let data = try Data(contentsOf: url)
                        let image = UIImage(data: data)
                        self.imageField.image = image
                    } catch {
                        print("Error loading image from URL: \(self.movieDetail?.imgPosterURL)")
                    }
                }
            }
        }
        progressBarField.transform = CGAffineTransform(scaleX: 1, y: 5)
        
        
    }
}

