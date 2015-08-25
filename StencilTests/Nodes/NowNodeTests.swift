import Foundation
import XCTest
import Stencil
import CatchingFire

class NowNodeTests: NodeTests {

  // MARK: Parsing

  func testParseDefaultNow() {
    let tokens = [ Token.Block(value: "now") ]
    let parser = TokenParser(tokens: tokens)

    AssertNoThrow {
      let nodes = try parser.parse()
      let node = nodes.first as! NowNode
      XCTAssertEqual(nodes.count, 1)
      XCTAssertEqual(node.format.variable, "\"yyyy-MM-dd 'at' HH:mm\"")
    }
  }

  func testParseNowWithFormat() {
    let tokens = [ Token.Block(value: "now \"HH:mm\"") ]
    let parser = TokenParser(tokens: tokens)

    AssertNoThrow {
      let nodes = try parser.parse()
      let node = nodes.first as! NowNode
      XCTAssertEqual(nodes.count, 1)
      XCTAssertEqual(node.format.variable, "\"HH:mm\"")
    }
  }

  // MARK: Rendering

  func testRenderNowNode() {
    let node = NowNode(format: Variable("\"yyyy-MM-dd\""))

    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let date = formatter.stringFromDate(NSDate())

    AssertNoThrow {
      let string = try node.render(context)
      XCTAssertEqual(string, date)
    }
  }

}

