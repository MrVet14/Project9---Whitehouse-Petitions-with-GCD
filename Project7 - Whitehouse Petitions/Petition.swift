//
//  Petition.swift
//  Project7 - Whitehouse Petitions
//
//  Created by Vitali Vyucheiski on 3/17/22.
//

import Foundation

struct Petition: Codable {
    var title:String
    var body: String
    var signatureCount: Int
}
