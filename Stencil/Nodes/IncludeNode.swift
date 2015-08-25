import Foundation
import PathKit

public struct Transformer {
  public let closure: String -> String

  public static func trim(input: String) -> String {
    return (input as NSString).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
  }
  
  public static func trim() -> Transformer {
    return Transformer() { trim($0) }
  }
}

public class IncludeNode : Node {
  public let templateName:String
  public let transformers: [Transformer]

  public class func parse(parser:TokenParser, token:Token) throws -> Node {
    let components = token.contents.componentsSeparatedByString("\"")

    guard components.count == 3 else {
      throw ParseError(cause: .InvalidArgumentCount, token: token, message: "Tag takes one argument, the template file to be included")
    }
    
    var transformers: [Transformer] = []
    if let lastComponent = components.last where lastComponent != "" {
      let transformerComponents = lastComponent.componentsSeparatedByString(" | ")
      for transformerName in transformerComponents {
        switch transformerName {
        case "trim":
          transformers.append(Transformer.trim())
          break
        default:
          // TODO: Error!
          break
        }
      }
    }

    return IncludeNode(templateName: components[1], transformers: transformers)
  }

  public init(templateName:String, transformers: [Transformer]? = nil) {
    self.templateName = templateName
    self.transformers = transformers ?? []
  }

  public func render(context: Context) throws -> String {
    let result = try renderTemplate(context, templateName: templateName) { (context, template) in
      return try template.render(context)
    }
    return transformers.reduce(result) { (transformedResult, transformer) in
      return transformer.closure(transformedResult)
    }
  }
}

