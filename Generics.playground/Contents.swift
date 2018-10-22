import UIKit

var str = "Hello, playground"
let numbers = [1, 2, 3]
let firstNumber = numbers[0]

var numbersAgain: Array<Int> = []
numbersAgain.append(1)
numbersAgain.append(2)
numbersAgain.append(3)

let firstNumberAgain = numbersAgain[0]
//numbersAgain.append("All hail Lord Farquaad")
let countryCodes = ["Arendelle": "AR", "Genovia": "GN", "Freedonia": "FD"]
let countryCode = countryCodes["Freedonia"]


let optionalName = Optional<String>.some("Princess Moana")
if let name = optionalName {}


func pairs<Key, Value>(from dictionary: [Key: Value]) -> [(Key, Value)] {
    return Array(dictionary)
}
let somePairs = pairs(from: ["minimum": 199, "maximum": 299])
// result is [("maximum", 299), ("minimum", 199)]

let morePairs = pairs(from: [1: "Swift", 2: "Generics", 3: "Rule"])
// result is [(2, "Generics"), (3, "Rule"), (1, "Swift")]


//func mid<T>(array: [T]) -> T? {
//    guard !array.isEmpty else { return nil }
//    return array.sorted(by: nil)[(array.count - 1) / 2]
//}
//
//mid(array: [3, 5, 1, 2, 4]) // 3
protocol Summable { static func +(lhs: Self, rhs: Self) -> Self }
extension Int: Summable {}
extension Double: Summable {}
extension String: Summable {}

func add<T: Summable>(x: T, y: T) -> T {
    return x + y
}
let addIntSum = add(x: 1, y: 2.2) // 3
let addDoubleSum = add(x: 1.0, y: 2) // 3
let addString = add(x: "Generics", y: " are Awesome!!! :]")

//
//extension Queue {
//    func peek() -> Element? {
//        return elements.first
//    }
//}
//q.enqueue(newElement: 5)
//q.enqueue(newElement: 3)
//q.peek() // 5
