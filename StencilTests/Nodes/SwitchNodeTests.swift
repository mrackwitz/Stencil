import Foundation
import XCTest
import Stencil
import CatchingFire

class SwitchNodeTests: NodeTests {
  
  // MARK: Parsing
  
  func testParseFullSwitch() {
    let tokens = [
      Token.Block(value: "switch value"),
      Token.Block(value: "case 1"),
      Token.Text(value: "a"),
      Token.Block(value: "case 2"),
      Token.Text(value: "b"),
      Token.Block(value: "default"),
      Token.Text(value: "c"),
      Token.Block(value: "endswitch")
    ]
    
    let parser = TokenParser(tokens: tokens)
    AssertNoThrow {
      let nodes = try parser.parse()
      XCTAssertEqual(nodes.count, 1)
      
      guard let node = nodes.first as? SwitchNode else { return XCTFail() }
      
      XCTAssertEqual(node.caseNodes.count, 2)
      XCTAssertEqual(node.defaultNodes.count, 1)
      
      guard let caseANode = node.caseNodes["1"]?.first as? TextNode else { return XCTFail() }
      guard let caseBNode = node.caseNodes["2"]?.first as? TextNode else { return XCTFail() }
      guard let defaultNode = node.defaultNodes.first as? TextNode else { return XCTFail() }
      
      XCTAssertEqual(node.variable.variable, "value")
      XCTAssertEqual(node.caseNodes.count, 2)
      XCTAssertEqual(caseANode.text, "a")
      XCTAssertEqual(caseBNode.text, "b")
      XCTAssertEqual(defaultNode.text, "c")
    }
  }
  
  func testParseEmptySwitch() {
    let tokens = [
      Token.Block(value: "switch value"),
      Token.Block(value: "endswitch")
    ]
    let parser = TokenParser(tokens: tokens)
    AssertNoThrow {
      let nodes = try parser.parse()
      XCTAssertEqual(nodes.count, 1)
      
      guard let node = nodes.first as? SwitchNode else { return XCTFail() }
      
      XCTAssertEqual(node.variable.variable, "value")
      XCTAssertEqual(node.caseNodes.count, 0)
      XCTAssertEqual(node.defaultNodes.count, 0)
    }
  }
  
  func assertParseEmptySwitch(tokens: [Token]) {
    let parser = TokenParser(tokens: tokens)
    AssertNoThrow {
      let nodes = try parser.parse()
      XCTAssertEqual(nodes.count, 1)
      
      guard let node = nodes.first as? SwitchNode else { return XCTFail() }
      
      XCTAssertEqual(node.variable.variable, "value")
      XCTAssertEqual(node.caseNodes.count, 0)
      XCTAssertEqual(node.defaultNodes.count, 0)
    }
  }
  
  func testParseEmptyDefaultSwitch() {
    assertParseEmptySwitch([
      Token.Block(value: "switch value"),
      Token.Block(value: "default"),
      Token.Block(value: "endswitch")
    ])
  }
  
  func testParseIgnoreCommentInSwitch() {
    assertParseEmptySwitch([
      Token.Block(value: "switch value"),
      Token.Comment(value: "Intentionally left empty."),
      Token.Block(value: "endswitch")
    ])
  }
  
  func testParseIgnoreWhitespaceTextInSwitch() {
    assertParseEmptySwitch([
      Token.Block(value: "switch value"),
      Token.Text(value: "    \n\r\n\t\t\n\t"),
      Token.Block(value: "endswitch")
    ])
  }
  
  func testParseFailOnNonWhitespaceTextInSwitch() {
    let tokens = [
      Token.Block(value: "switch value"),
      Token.Text(value: "undefined"),
      Token.Block(value: "endswitch")
    ]
    
    let parser = TokenParser(tokens: tokens)
    AssertThrows(ParseError(cause: .InvalidSwitchSyntax, token: tokens[1], message: "Unexpected non-whitespace text.")) {
      try parser.parse()
    }
  }
  
  func testParseSwitchWithoutEndSwitchError() {
    let tokens = [
      Token.Block(value: "switch value"),
    ]
    
    let parser = TokenParser(tokens: tokens)
    AssertThrows(ParseError(cause: .MissingEnd, token: tokens[0], message: "`endswitch` was not found.")) {
      try parser.parse()
    }
  }
  
  func testParseSwitchWithWrongBlockError() {
    let tokens = [
      Token.Block(value: "switch value"),
      Token.Block(value: "endif"),
    ]
    
    let parser = TokenParser(tokens: tokens)
    AssertThrows(ParseError(cause: .InvalidSwitchSyntax, token: tokens[0], message: "Expected `case`, `default` or `endswitch`.")) {
      try parser.parse()
    }
  }
  
  func testParseSwitchWithVariableError() {
    let tokens = [
      Token.Block(value: "switch value"),
      Token.Variable(value: "name"),
      Token.Block(value: "endswitch"),
    ]
    
    let parser = TokenParser(tokens: tokens)
    AssertThrows(ParseError(cause: .InvalidSwitchSyntax, token: tokens[1], message: "Unexpected variable in switch context.")) {
      try parser.parse()
    }
  }
  
  // MARK: Rendering
  
  func testSwitchRenderCase() {
    let node = SwitchNode(variable: Variable("name"),
      caseNodes: ["Kyle": [TextNode(text: "F")], "Marius": [TextNode(text: "R")]],
      defaultNodes: [TextNode(text: "?")])
    
    AssertNoThrow {
      let string = try node.render(context)
      XCTAssertEqual(string, "F")
    }
  }
  
  func testSwitchRenderDefaultIfNoCaseMatches() {
    let node = SwitchNode(variable: Variable("name"),
      caseNodes: ["Boris": [TextNode(text: "B")]],
      defaultNodes: [TextNode(text: "?")])
    
    AssertNoThrow {
      let string = try node.render(context)
      XCTAssertEqual(string, "?")
    }
  }
  
  func testSwitchRenderDefaultForUnknownVar() {
    let node = SwitchNode(variable: Variable("unknown"), caseNodes: [:], defaultNodes: [TextNode(text: "?")])
    
    AssertNoThrow {
      let string = try node.render(context)
      XCTAssertEqual(string, "?")
    }
  }
  
}
