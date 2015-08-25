public class SwitchNode : Node {
  public let variable:Variable
  public let caseNodes: [String : [Node]]
  public let defaultNodes: [Node]
  
  public init(variable: Variable, caseNodes: [String : [Node]], defaultNodes: [Node]) {
    self.variable = variable
    self.caseNodes = caseNodes
    self.defaultNodes = defaultNodes
  }
  
  class func parseTail(parser:TokenParser, token:Token) throws -> (defaultNodes: [Node]?, caseNodes: [String : [Node]]) {
    var defaultNodes: [Node]?
    var caseNodes = [String : [Node]]()
    while let token = parser.nextToken() {
      switch token {
      case .Block(_):
        let type = token.components()[0]
        switch type {
        case "case":
          let pattern = token.components()[1]
          let nodes = try parser.parse(until(["case", "default", "endswitch"]))
          caseNodes[pattern] = nodes
          continue
        case "default":
          defaultNodes = try parser.parse(until(["case", "default", "endswitch"]))
          continue
        case "endswitch":
          return (defaultNodes, caseNodes)
        default:
          throw ParseError(cause: .InvalidSwitchSyntax, token: token, message: "Expected `case`, `default` or `endswitch`.")
        }
      case .Variable(_):
        throw ParseError(cause: .InvalidSwitchSyntax, token: token, message: "Unexpected variable in switch context.")
      case .Text(let contents):
        // Guard against non-whitespace text
        let characterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet().invertedSet
        guard (contents as NSString).rangeOfCharacterFromSet(characterSet).length == 0 else {
          throw ParseError(cause: .InvalidSwitchSyntax, token: token, message: "Unexpected non-whitespace text.")
        }
        // Ignore whitespace between cases
        continue
      case .Comment(_):
        // Ignore comments between cases
        continue
      }
    }
    throw ParseError(cause: .MissingEnd, token: token, message: "Expected `endswitch`.")
  }
  
  public class func parse(parser:TokenParser, token:Token) throws -> Node {
    let variable = token.components()[1]
    let (defaultNodes, caseNodes) = try parseTail(parser, token: token)
    return SwitchNode(variable: Variable(variable), caseNodes: caseNodes, defaultNodes: defaultNodes ?? [])
  }
  
  public func render(context: Context) throws -> String {
    let maybeResult: AnyObject? = variable.resolve(context)
    
    let nodes: [Node]
    if let result = maybeResult {
      let resultString = String(result)
      //throw Template.Error.SwitchVariableValueIsNotStringConvertible(name: String, value: AnyObject)
      if let matchingNodes = caseNodes[resultString] {
        nodes = matchingNodes
      } else {
        nodes = defaultNodes
      }
    } else {
      nodes = defaultNodes
    }
    
    context.push()
    let output = try renderNodes(nodes, context: context)
    context.pop()
    
    return output
  }
}
