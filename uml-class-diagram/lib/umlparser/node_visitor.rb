module Umlparser
  class NodeVisitor < VoidVisitorAdapter
    def visit(node, tree)
      case node
      when Java::ComGithubJavaparserAstBody::ClassOrInterfaceDeclaration
        umlnode = node.interface? ? InterfaceNode.new(node) : ClassNode.new(node)
        tree[umlnode.name] = umlnode
        super(node, umlnode.children)
      when Java::ComGithubJavaparserAstBody::FieldDeclaration
        modifier = (m = node.modifiers.first) ? m.name.downcase.to_sym : ''
        node.variables.each do |variable|
          umlnode = AttributeNode.new(modifier, variable)
          tree[umlnode.name] = umlnode
        end
      when Java::ComGithubJavaparserAstBody::MethodDeclaration
        umlnode = MethodNode.new(node)
        tree[umlnode.name] = umlnode
      when Java::ComGithubJavaparserAstBody::ConstructorDeclaration
        umlnode = ConstructorNode.new(node)
        tree[umlnode.name] = umlnode
      else
        super(node, tree)
      end
    end
  end
end

