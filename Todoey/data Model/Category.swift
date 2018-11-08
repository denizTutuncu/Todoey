//
//  Category.swift
//  Todoey
//
//  Created by Deniz Tutuncu on 11/6/18.
//  Copyright © 2018 Deniz Tutuncu. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name : String = ""
    @objc dynamic var color : String = ""
    let items = List<Item>()
    
}
