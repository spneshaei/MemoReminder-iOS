//
//  MainAsync.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/16/21.
//

import Foundation

func main(code: @escaping () -> Void) {
    DispatchQueue.main.async(execute: code)
}
