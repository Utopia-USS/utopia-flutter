//
//  SaveFileDto.swift
//  Pods
//
//  Created by jakub on 21/02/2025.
//
import FlutterMacOS

class SaveFileDto {
    let name: String
    let mime: String
    
    init(from map: NSDictionary) {
        name = map["name"] as! String
        mime = map["mime"] as! String
    }
}

class SaveFileDtoFromFile: SaveFileDto {
    let path: String
    
    override init(from map: NSDictionary) {
        path = map["path"] as! String
        super.init(from: map)
    }
}

class SaveFileDtoFromUrl: SaveFileDto {
    let url: String
    
    override init(from map: NSDictionary) {
        url = map["url"] as! String
        super.init(from: map)
    }
}

class SaveFileDtoFromBytes: SaveFileDto {
    let bytes: FlutterStandardTypedData
    
    override init(from map: NSDictionary) {
        bytes = map["bytes"] as! FlutterStandardTypedData
        super.init(from: map)
    }
}

class SaveFileDtoFromAsset: SaveFileDto {
    let key: String
    
    override init(from map: NSDictionary) {
        key = map["key"] as! String
        super.init(from: map)
    }
}
