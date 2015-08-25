import Foundation
import XCTest
import Stencil
import CatchingFire

class IfNodeTests: NodeTests {

  // MARK: Parsing

  func testParseIf() {
    let tokens = [
      Token.Block(value: "if value"),
      Token.Text(value: "true"),
      Token.Block(value: "else"),
      Token.Text(value: "false"),
      Token.Block(value: "endif")
    ]

    let parser = TokenParser(tokens: tokens)
    AssertNoThrow {
      let nodes = try parser.parse()
      let node = nodes.first as! IfNode
      let trueNode = node.trueNodes.first as! TextNode
      let falseNode = node.falseNodes.first as! TextNode

      XCTAssertEqual(nodes.count, 1)
      XCTAssertEqual(node.variable.variable, "value")
      XCTAssertEqual(node.trueNodes.count, 1)
      XCTAssertEqual(trueNode.text, "true")
      XCTAssertEqual(node.falseNodes.count, 1)
      XCTAssertEqual(falseNode.text, "false")
    }
  }

  func testParseIfNot() {
    let tokens = [
      Token.Block(value: "ifnot value"),
      Token.Text(value: "false"),
      Token.Block(value: "else"),
      Token.Text(value: "true"),
      Token.Block(value: "endif")
    ]

    let parser = TokenParser(tokens: tokens)
    AssertNoThrow {
      let nodes = try parser.parse()
      let node = nodes.first as! IfNode
      let trueNode = node.trueNodes.first as! TextNode
      let falseNode = node.falseNodes.first as! TextNode

      XCTAssertEqual(nodes.count, 1)
      XCTAssertEqual(node.variable.variable, "value")
      XCTAssertEqual(node.trueNodes.count, 1)
      XCTAssertEqual(trueNode.text, "true")
      XCTAssertEqual(node.falseNodes.count, 1)
      XCTAssertEqual(falseNode.text, "false")
    }
  }

  func testParseIfWithoutEndIfError() {
    let tokens = [
      Token.Block(value: "if value"),
    ]

    let parser = TokenParser(tokens: tokens)
    AssertThrows(ParseError(cause: .MissingEnd, token: tokens[0], message: "`endif` was not found.")) {
      try parser.parse()
    }
  }

  func testParseIfNotWithoutEndIfError() {
    let tokens = [
      Token.Block(value: "ifnot value"),
    ]

    let parser = TokenParser(tokens: tokens)
    AssertThrows(ParseError(cause: .MissingEnd, token: tokens[0], message: "`endif` was not found.")) {
      // ifnot: `endif` was not found."
      try parser.parse()
    }
  }

  // MARK: Rendering

  func testIfNodeRenderTruth() {
    let node = IfNode(variable: "items", trueNodes: [TextNode(text: "true")], falseNodes: [TextNode(text: "false")])
    
    AssertNoThrow {
      let string = try node.render(context)
      XCTAssertEqual(string, "true")
    }
  }

  func testIfNodeRenderFalse() {
    let node = IfNode(variable: "unknown", trueNodes: [TextNode(text: "true")], falseNodes: [TextNode(text: "false")])

    AssertNoThrow {
      let string = try node.render(context)
      XCTAssertEqual(string, "false")
    }
  }

}
