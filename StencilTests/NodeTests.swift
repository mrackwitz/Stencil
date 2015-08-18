import Foundation
import XCTest
import Stencil
import CatchingFire

enum ErrorNodeError : ErrorType {
  case ExpectedError
}

class ErrorNode : Node {
  func render(context: Context) throws -> String {
    throw ErrorNodeError.ExpectedError
  }
}

class NodeTests: XCTestCase {
  var context:Context!

  override func setUp() {
    context = Context(dictionary: [
      "name": "Kyle",
      "age": 27,
      "items": [1,2,3],
      ])
  }
}

class TextNodeTests: NodeTests {
  func testTextNodeResolvesText() {
    let node = TextNode(text:"Hello World")
    AssertNoThrow {
      let string = try node.render(context)
      XCTAssertEqual(string, "Hello World")
    }
  }
}

class VariableNodeTests: NodeTests {
  func testVariableNodeResolvesVariable() {
    let node = VariableNode(variable:Variable("name"))
    AssertNoThrow {
      let string = try node.render(context)
      XCTAssertEqual(string, "Kyle")
    }
  }

  func testVariableNodeResolvesNonStringVariable() {
    let node = VariableNode(variable:Variable("age"))
    AssertNoThrow {
      let string = try node.render(context)
      XCTAssertEqual(string, "27")
    }
  }
}

class RenderNodeTests: NodeTests {
  func testRenderingNodes() {
    let nodes = [TextNode(text:"Hello "), VariableNode(variable: "name")] as [Node]
    AssertNoThrow {
      let result = try renderNodes(nodes, context: context)
      XCTAssertEqual(result, "Hello Kyle")
    }
  }

  func testRenderingNodesWithFailure() {
    let nodes = [TextNode(text:"Hello "), VariableNode(variable: "name"), ErrorNode()] as [Node]
    AssertThrows(ErrorNodeError.ExpectedError) {
      try renderNodes(nodes, context: context)
    }
  }
}

class ForNodeTests: NodeTests {
  func testForNodeRender() {
    let node = ForNode(variable: "items", loopVariable: "item", nodes: [VariableNode(variable: "item")], emptyNodes:[])
    AssertNoThrow {
      let result = try node.render(context)
      XCTAssertEqual(result, "123")
    }
  }
}

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

/// SWITCH

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

