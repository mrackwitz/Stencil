import Foundation
import XCTest
import Stencil
import CatchingFire

class BindNodeTests: NodeTests {
  
  // MARK: Parsing
  
  func testParseBind() {
    let tokens = [
      Token.Block(value: "bind name"),
      Token.Text(value: "Marius"),
      Token.Block(value: "endbind"),
    ]
    
    let parser = TokenParser(tokens: tokens)
    AssertNoThrow {
      let nodes = try parser.parse()
      
      XCTAssertEqual(nodes.count, 1)
      
      let node = nodes.first as! BindNode
      XCTAssertEqual(node.variable.variable, "name")
      XCTAssertEqual(node.nodes.count, 1)
      
      let textNode = node.nodes.first as! TextNode
      XCTAssertEqual(textNode.text, "Marius")
    }
  }
  
  func testParseBindWithoutEndBindError() {
    let tokens = [
      Token.Block(value: "bind name"),
    ]
    
    let parser = TokenParser(tokens: tokens)
    AssertThrows(ParseError(cause: .MissingEnd, token: tokens[0], message: "`endbind` was not found.")) {
      try parser.parse()
    }
  }

  // MARK: Rendering
  
  func testBindRender() {
    let node = BindNode(variable: "name", nodes: [TextNode(text: "Marius")])
    
    AssertNoThrow {
      let string = try node.render(context)
      XCTAssertEqual(string, "")
      XCTAssertEqual(context["name"] as? String, "Marius")
    }
  }
  
}
