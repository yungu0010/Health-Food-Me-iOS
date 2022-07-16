//
//  ReviewRouter.swift
//  HealthFoodMe
//
//  Created by Junho Lee on 2022/07/16.
//

import Alamofire

enum ReviewRouter {
    
}

extension ReviewRouter: BaseRouter {
    var method: HTTPMethod {
        switch self {
        default :
            return .get
        }
    }
    
    var path: String {
        switch self {
        default:
            return ""
        }
    }
    
    var parameters: RequestParams {
        switch self {
        default:
            return .requestPlain
        }
    }
}
