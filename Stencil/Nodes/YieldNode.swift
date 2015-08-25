class Box<T> {
  let value: T
  
  init(_ value: T) {
    self.value = value
  }
}


public class YieldNode : Node {
  static let blockContextKey = "block"
  
  public init() {
  }
  
  public class func parse(parser: TokenParser, token: Token) throws -> Node {
    return YieldNode()
  }
  
  public func render(context: Context) throws -> String {
    guard let box = context[YieldNode.blockContextKey] as? Box<(Context) -> String> else {
      throw Template.Error.NoBlockInContext
    }
    return box.value(context)
  }
}

extension Template {
  /// Renders by setting a closure as yield block.
  public func call(context: Context, yieldBlock: (Context) -> String) throws -> String {
    context.push([YieldNode.blockContextKey : Box(yieldBlock)])
    let result = try render(context)
    context.pop()
    return result
  }
}
