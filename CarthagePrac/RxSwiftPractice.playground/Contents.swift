import UIKit
import RxSwift
import RxCocoa
import Foundation

//date to string to time

//2020-02-19T16:48:02.968676
//2019-01-30T11:48:50.198724

//스위처 MAC Address EBC6787249F1
//링커 MAC Address 30AEA4C3A788

var disposeBag = DisposeBag()

class HttpHelper {
	
	var accessToken: String! = ""
	
	enum HTTPMethod: String {
		case post   = "POST"
		case get    = "GET"
		case put    = "PUT"
		case delete = "DELETE"
	}
	
	func setAccessToken(accessToken: String) {
		self.accessToken = accessToken
	}
	
	func getURLRequest(url: URL, httpMethod: HTTPMethod, parameters: [String: Any]? = nil) -> URLRequest {
		var request = URLRequest(url: url)
		request.timeoutInterval = 10.0
		request.httpMethod = httpMethod.rawValue
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		if self.accessToken == "" {
			self.accessToken = "jBe6OdWjCIDEYW4XKCsN6nm8J63IfU9FRPW8aU+tz4c="
		}
		request.addValue(accessToken, forHTTPHeaderField: "Authorization")
		
		guard let parameters = parameters else { return request }
		
		switch httpMethod {
		case .get:
			request.url = URL(string:"\(url)\(getParameterString(parameters: parameters))")
			
		case .post:
			do {
				request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
			} catch let error {
				print(error)
			}
			
		case .put:
			do {
				request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
			} catch let error {
				print(error)
			}
			
		case .delete:
			do {
				request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
			} catch let error {
				print(error)
			}
		}
		
		return request
	}
	
	func getParameterString(parameters: [String: Any]? = nil) -> String {
		guard let parameters = parameters else { return "" }
		var urlValues = [String]()
		parameters.forEach { (key: String, value: Any) in
			guard let value = value as? String else { return }
			if let encodedValue = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
				urlValues.append(key + "=" + encodedValue)
			}
		}
		
		let firstValue = urlValues.removeFirst()
		return urlValues.reduce("?\(firstValue)") { return $0 + "&" + $1 }
	}
}

class HistoryCommand {
	var commandId = "-1"
	var macAddress: String?
	var date: String?
	var commandNumber: String?
	var name: String?
	
	init(commandId: String, macAddress: String, date: String, commandNumber: String, name: String) {
		self.commandId = commandId
		self.macAddress = macAddress
		self.date = date
		self.commandNumber = commandNumber
		self.name = name
	}
}

func requestSensorDataLastOneHour(macAddress: String) -> Observable<Any> {
	let url = URL(string: "https://dev.api.mobile.i-o.studio/v1/devices/30AEA4C3A788/sensors/last/one/hour/")!
	let request = HttpHelper().getURLRequest(url: url, httpMethod: .get)
	return URLSession.shared.rx.json(request: request).timeout(10, scheduler: MainScheduler.instance)
}

func requestCurrentCommandList(macAddress: String) {
	requestSensorDataLastOneHour(macAddress: macAddress)
		.subscribe(onNext: { json in
			print(json)
			guard
				let data = json as? [String: Any],
				let results = data["command_list"] as? [Any] else { return }
			
			results.forEach {
				guard
					let result = $0 as? [String: Any],
					let id = result["command_id"] as? String,
					let macAddress = result["mac_address"] as? String,
					let date = result["created_at"] as? String,
					let commandNumber = result["command_no"] as? String,
					let name = result["name"] as? String else { return }
				
				let historyCommand = HistoryCommand(commandId: id, macAddress: macAddress, date: date, commandNumber: commandNumber, name: name)
			}
		}).disposed(by: disposeBag)
}
//"created_at": "2019-05-03T10:16:23.097283"
//requestCurrentCommandList(macAddress: "30AEA4C3A788")

let dateString: String = "2018-05-13 15:05:40"
let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
let date: Date? = dateFormatter.date(from: dateString)

let dateString2: String = "2019-04-29T12:24:35.716901"
dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
let date2: Date? = dateFormatter.date(from: dateString2)

dateFormatter.dateFormat = "HH:mm:ss"
dateFormatter.string(from: date2!)
