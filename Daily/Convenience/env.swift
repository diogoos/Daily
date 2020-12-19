//
//  env.swift
//  Daily
//
//  Created by Diogo Silva on 12/07/20.
//

import Foundation

func env(_ argument: String, autoprefix: Bool = true) -> Bool {
    var argument = argument
    if !argument.starts(with: "-") && autoprefix { argument = "--" + argument }
    return CommandLine.arguments.contains(argument)
}

