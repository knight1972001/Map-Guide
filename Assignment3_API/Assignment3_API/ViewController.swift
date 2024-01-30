//
//  ViewController.swift
//  Assignment3_API
//
//  Created by Đỗ Mai Khánh Nhi on 24/03/2023.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var searchTextField: UITextField!
    var movies: [Movie] = []
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func searchButton(_ sender: Any) {
        searchMovie(searchString: searchTextField.text ?? ""){ result in
            self.movies = result
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchMovie(searchString: "Batman"){ result in
            self.movies = result
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(movies[indexPath.row].title + " clicked!")
        print(movies[indexPath.row].imdbID);
        if let vc = storyboard?.instantiateViewController(withIdentifier: "movieViewController") as? MovieViewController{
            vc.imdbID = movies[indexPath.row].imdbID
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movieCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
          
        let movie = movies[indexPath.row]
        movieCell.titleTextField.text = movie.title
        if let url = URL(string: movie.posterURL) {
            do {
                let data = try Data(contentsOf: url)
                let image = UIImage(data: data)
                movieCell.imageField.image = image
            } catch {
                print("Error loading image from URL: \(movie.posterURL)")
            }
        }
        movieCell.yearTextField.text = movie.year
        movieCell.typeTextField.text = movie.type
        return movieCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 80
    }
}
