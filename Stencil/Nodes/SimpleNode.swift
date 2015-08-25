public class SimpleNode : Node {
  let handler: (Context) throws -> String
  
  public init(handler: (Context) throws -> String) {
    self.handler = handler
  }
  
  public func render(context:Context) throws -> String {
    return try handler(context)
  }
}
