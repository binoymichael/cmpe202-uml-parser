module Umlparser
  class MethodStatementVisitor < VoidVisitorAdapter
    def visit(node, tree)
      case node
      when Java::ComGithubJavaparserAstExpr::VariableDeclarationExpr
        node.variables.each do |v|
          if v.type.is_a?(Java::ComGithubJavaparserAstType::ClassOrInterfaceType)
            tree[v.name.identifier] = {type: v.type.to_s, calls: []}
          end
        end
        super(node, tree)
      when Java::ComGithubJavaparserAstExpr::MethodCallExpr
        if node.scope.present?
          scope = node.scope.get.to_s
          if tree.key?(scope)
            tree[scope][:calls] << node.name.identifier
          else
            tree[scope] = {calls: [node.name.identifier]}
          end
        end

        super(node, tree)
      else
        super(node, tree)
      end
    end
  end
end



