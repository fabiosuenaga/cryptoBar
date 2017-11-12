//
//  WindowController.swift
//  TouchFart
//
//  Created by Hung Truong on 10/27/16.
//  Copyright © 2016 Hung Truong. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON

fileprivate extension NSTouchBarCustomizationIdentifier {
    static let touchBar = NSTouchBarCustomizationIdentifier("cryptoCoin")
}

fileprivate extension NSTouchBarItemIdentifier {
    static let quotationLTC      = NSTouchBarItemIdentifier("LTC: ")
    static let quotationBTC   = NSTouchBarItemIdentifier("BTC: ")
}

class WindowController: NSWindowController, NSTouchBarDelegate {
    
    var quotationItem: NSStatusItem?
    var button: NSStatusBarButton?
    var ticker: Ticker?
    weak var timer: Timer?
    
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier    = .touchBar
        touchBar.defaultItemIdentifiers     = [.quotationLTC, .quotationBTC]
        
        return touchBar
    }
    
    @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
        let touchBarItem    = NSCustomTouchBarItem(identifier: identifier)
        touchBarItem.view   = NSButton(title: identifier.rawValue, target: self, action: nil)
        return touchBarItem
    }
    
    func getQuotation() -> Void {
        
        // Workaround for linker bug  http://stackoverflow.com/a/24026327/279890
        let NSVariableStatusItemLength: CGFloat = -1.0;
        
        self.quotationItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        self.button = self.quotationItem?.button
        self.button?.title = "x"
        
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            
            self?.makeRequest("mb-ltc") { response in
                
                self?.ticker = nil
                self?.ticker = Ticker.init(json: response.0!)
                var last = (self?.ticker!.last!)!
                var offset = 0;
                
                if( last.characters.count > 5 ){
                    offset = 5
                } else {
                    offset = last.characters.count
                }
                
                let index = last.index(last.startIndex, offsetBy: offset)
                self?.button?.title = "LTC: " + last.substring(to: index)
                //                self?.button?.attributedTitle =
                
            }
            
        }
        
    }
    
    func makeRequest(_ section: String, completionHandler:@escaping (_ responseObject: JSON?, _ error: NSError?) -> ()) {
        
        let requestURL: String
        
        switch section {
        case "mb-ltc":
            requestURL = "https://www.mercadobitcoin.net/api/v1/ticker_litecoin/"
        case "mb-btc":
            requestURL = ""
        case "fox-btc":
            requestURL = ""
        default:
            requestURL = ""
        }
        
        Alamofire.request(requestURL).responseJSON { response in
            
            print(response)
            if let status = response.response?.statusCode {
                switch(status){
                case 200:
                    completionHandler(JSON(data: response.data!) as JSON, nil)
                default:
                    completionHandler(nil,NSError(domain: requestURL, code: (response.response?.statusCode)!, userInfo: nil))
                }
            }
            
        }
        
    }
}
