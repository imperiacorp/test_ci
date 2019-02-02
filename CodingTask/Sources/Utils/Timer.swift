//
//  Timer.swift
//  CodingTask
//
//  Created by Dmitriy Gonchar on 6/28/18.
//  Copyright © 2018 Dmitriy Gonchar. All rights reserved.
//

import Foundation

class RepeatingTimer {

    var eventHandler: (() -> Void)?

    private let timeInterval: TimeInterval
    private let threadType: ThreadType

    enum ThreadType {
        case main
        case other
    }

    init(timeInterval: TimeInterval, type: ThreadType) {
        self.timeInterval = timeInterval
        self.threadType = type
    }

    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
        t.setEventHandler(handler: { [weak self] in
            guard let `self` = self else { return }
            switch self.threadType {
            case .main:
                DispatchQueue.main.async {
                    self.eventHandler?()
                }
            case .other:
                self.eventHandler?()
            }
        })
        return t
    }()

    func start() {
        timer.resume()
    }

    deinit {
        timer.setEventHandler {}
        timer.cancel()
        eventHandler = nil
    }
}
