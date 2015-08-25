import Foundation

public enum RenderError : ErrorType {
  case TemplateNotFound(name: String, paths:[String])
  case TemplateLoaderNotInContext
}

public struct ParseError : ErrorType {
  public enum Cause : ErrorType {
    case InvalidArgumentCount
    case MissingEnd
    case InvalidForSyntax
    case ExtendsUsedMoreThanOnce
    case InvalidSwitchSyntax
  }

  let cause: Cause
  let token: Token
  let message: String
  
  public init(cause: Cause, token: Token, message: String) {
    self.cause = cause
    self.token = token
    self.message = message
  }
  
  public var _code: Int {
    return cause._code
  }
  
  public var _domain: String {
    return cause._domain
  }
  
  var description:String {
    return "\(token.components().first!): \(message)"
  }
}

public protocol Node {
  /// Return the node rendered as a string, or returns a failure
  func render(context:Context) throws -> String
}

extension Node {
  func renderTemplate(context: Context, templateName: String, @noescape render: (Context, Template) throws -> String) throws -> String {
    guard let loader = context["loader"] as? TemplateLoader else {
      throw RenderError.TemplateLoaderNotInContext
    }
    guard let template = loader.loadTemplate(templateName) else {
      let paths = loader.paths.map({ String($0) })
      throw RenderError.TemplateNotFound(name: templateName, paths: paths)
    }
    
    return try render(context, template)
  }
}

public func renderNodes(nodes:[Node], context:Context) throws -> String {
  var result = ""
  for item in nodes {
    result += try item.render(context)
  }
  return result
}
