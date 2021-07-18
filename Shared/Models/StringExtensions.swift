//
//  StringExtensions.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/18/21.
//

import Foundation

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
