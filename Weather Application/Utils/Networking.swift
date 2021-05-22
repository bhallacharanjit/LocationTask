//
//  Networking.swift
//  Policy Track
//
//  Created by charanjit singh on 27/04/21.
//

import Foundation
import Alamofire


class Networking {
    
    
    var delegate: NetworkingDelegate?
    
    func callAPI(url:String, data:Dictionary<String,Any>?, method: HTTPMethod) {
        
        AF.request(url , method: method , parameters: data, encoding: JSONEncoding.default)
            .responseJSON { (response) in
                if self.delegate != nil {
                    self.delegate?.NetworkingFinished(response: response)
                }
            }
    }
}
