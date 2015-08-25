public class BindNode : Node {
  public let variable: Variable
  public let nodes: [Node]
  
  public init(variable: String, nodes: [Node]) {
    self.variable = Variable(variable)
    self.nodes = nodes
  }
  
  public class func parse(parser: TokenParser, token: Token) throws -> Node {
    let variable = token.components()[1]
    let nodes = try parser.parse(until(["endbind"]))
    guard let endToken = parser.nextToken() where endToken.contents == "endbind" else {
      throw ParseError(cause: .MissingEnd, token: token, message: "`endbind` was not found.")
    }
    return BindNode(variable: variable, nodes: nodes)
  }
  
  public func render(context: Context) throws -> String {
    context[variable.variable] = try renderNodes(nodes, context: context)
    return ""
  }
  
}
