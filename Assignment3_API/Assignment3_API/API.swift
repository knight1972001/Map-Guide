//
//  API.swift
//  Assignment3_API
//
//  Created by Đỗ Mai Khánh Nhi on 24/03/2023.
//

import Foundation

var API_URL = "http://www.omdbapi.com/?apikey=5aa2b3be"

struct Movie: Decodable {
    let title: String
    let year: String
    let imdbID: String
    let type: String
    let posterURL: String
}

struct MovieDetail: Decodable{
    let title: String
    let released: String
    let rated: String
    let runtime: String
    let genre: String
    let director: String
    let award: String
    let imdbRating: Double
    let imgPosterURL: String
}

func getJSONData(from url: URL) async throws -> [String: Any] {
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw NSError(domain: "com.example.app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
    }
    
    guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
        throw NSError(domain: "com.example.app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON data"])
    }
    
    return jsonObject
}

//func searchMovie(searchString: String) async -> [Movie]{
//    var movies = [Movie]()
//    do {
//        let url = URL(string: "http://www.omdbapi.com/?apikey=5aa2b3be&s="+searchString)!
//        let json = try await getJSONData(from: url)
//
//        guard let jsonArray = json["Search"] as? [[String: Any]] else {
//            throw NSError(domain: "com.example.app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON data"])
//        }
//
//        for jsonObject in jsonArray {
//            let title = jsonObject["Title"] as? String ?? ""
//            let year = jsonObject["Year"] as? String ?? ""
//            let imdbID = jsonObject["imdbID"] as? String ?? ""
//            let type = jsonObject["Type"] as? String ?? ""
//            let posterURLString = jsonObject["Poster"] as? String ?? ""
//            let movie = Movie(title: title, year: year, imdbID: imdbID, type: type, posterURL: posterURLString)
//            movies.append(movie)
//        }
//        return movies;
//    }catch {
//        print("Error: \(error.localizedDescription)")
//    }
//    return movies;
//}

func searchMovie(searchString: String, completion: @escaping ([Movie]) -> Void) {
    let searchString = searchString.replacingOccurrences(of: " ", with: "%20")

    let urlString = API_URL + "&s=" + searchString
   
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return
    }
    let session = URLSession.shared
    let dataTask = session.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error: \(error.localizedDescription)")
            return
        }
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("Invalid response")
            return
        }
        guard let data = data else {
            print("Invalid data")
            return
        }
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            guard let search = json?["Search"] as? [[String: Any]] else {
                print("Invalid JSON")
                return
            }
            let movies = try search.map { searchItem -> Movie in
                guard let title = searchItem["Title"] as? String,
                      let year = searchItem["Year"] as? String,
                      let imdbID = searchItem["imdbID"] as? String,
                      let type = searchItem["Type"] as? String,
                      let posterURL = searchItem["Poster"] as? String else {
                    throw NSError(domain: "com.example.app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON data"])
                }
                return Movie(title: title, year: year, imdbID: imdbID, type: type, posterURL: posterURL)
            }
            completion(movies)
        } catch {
            print("Parsing error: \(error.localizedDescription)")
        }
    }
    dataTask.resume()
}
func getMovieDetail(imdbId: String, completion: @escaping (MovieDetail) -> Void) {
    let urlString = API_URL + "&i=" + imdbId
  
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return
    }
    let session = URLSession.shared
    let dataTask = session.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error: \(error.localizedDescription)")
            return
        }
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("Invalid response")
            return
        }
        guard let data = data else {
            print("Invalid data")
            return
        }
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("Invalid JSON")
                return
            }
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("Invalid JSON at serialization")
                return
            }
            print("json after serialization: \(json)")
           
            guard let title = json["Title"] as? String,
                  let released = json["Released"] as? String,
                  let rated = json["Rated"] as? String,
                  let runtime = json["Runtime"] as? String,
                  let genre = json["Genre"] as? String,
                  let director = json["Director"] as? String,
                  let award = json["Awards"] as? String,
                  let imdbRatingString = json["imdbRating"] as? String,
                  let imdbRating = Double(imdbRatingString),
                  let imgPosterURL = json["Poster"] as? String
            else {
                print("Invalid JSON data at key")
                return
            }
//            let movieDetail = MovieDetail(title: title, released: released, rated: rated, runtime: runtime, genre: genre, director: director, award: award, imdbRating: imdbRating, imgPosterURL: imgPosterURL)
//            print("Finished converted: \(title)")
            let movieDetail = MovieDetail(title: title, released: released, rated: rated, runtime: runtime, genre: genre, director: director, award: award, imdbRating: imdbRating, imgPosterURL: imgPosterURL)
            completion(movieDetail)

        } catch {
            print("Parsing error: \(error.localizedDescription)")
        }
    }
    dataTask.resume()
}



