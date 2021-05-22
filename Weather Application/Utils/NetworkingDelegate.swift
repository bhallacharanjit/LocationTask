//
//  NetworkingDelegate.swift
//  Policy Track
//
//  Created by charanjit singh on 27/04/21.
//

import Foundation
import Alamofire

protocol NetworkingDelegate {
    
    func NetworkingFinished(response:AFDataResponse<Any>)
    
}
