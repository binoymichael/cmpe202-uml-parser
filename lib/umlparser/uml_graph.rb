module Umlparser
  class UmlGraph
    attr_accessor :ast
    def initialize(ast)
      @ast = ast.dup
    end

    def write(filename)
      scrub!

      File.open(filename, 'w') do |f|
        ast.each do |klass_name, klass_node|
          text_uml_for(klass_node) do |line|
            f.puts line
          end
        end
      end
    end

    private

    def scrub!
      ast.each do |klass_name, klass_node|
        klass_node.children.each do |child_name, child_node|
          if child_node.is_a? AttributeNode 
            attribute = child_node

            if attribute.association? && attribute.visible?
              if ast.key?(attribute.type)
                hide_reverse_associations(attribute, klass_node)
              else
                # make association inline
                child_node.association = false
              end
            end
          elsif child_node.is_a? MethodNode
            method = child_node

            child_node.parameters.each do |_, param_type|
              if (a = ast[param_type]) && a.is_a?(InterfaceNode)
                klass_node.dependencies << param_type
              end
            end
          end
        end
      end
    end

    def text_uml_for(class_node)
      associations = []
      dependencies = []
      attributes = []
      methods = []

      class_or_interface = class_node.is_a?(ClassNode) ? 'class' : 'interface'
      header_string = "#{class_node.modifier} #{class_or_interface} #{class_node.name}" 
      header_string += " extends #{class_node.extends}" if class_node.extends.any?
      header_string += " implements #{class_node.implements.join(', ')}" if class_node.implements.any?

      class_node.children.each do |_, child_node|
        next unless child_node.visible?
        if child_node.is_a?(AttributeNode)
          if child_node.association?
            associations << " * @assoc #{child_node.reverse_association || '-'} - #{child_node.association} #{child_node.type}"
          else
            attributes << "\t#{child_node.modifier} #{child_node.formatted_type} #{child_node.name};"
          end
        elsif child_node.is_a?(MethodNode)
          param_string = child_node.parameters.map { |k,v| "#{v} #{k}" }.join(', ')
          methods << "\t#{child_node.modifier} #{child_node.type} #{child_node.name}(#{param_string});"
        end
      end

      class_node.dependencies.each do |type|
        dependencies << " * @depend - - - #{type}"
      end

      yield '/**'
      associations.each { |a| yield a }
      dependencies.each { |d| yield d }
      yield ' */'
      yield header_string
      yield '{'
      attributes.each { |a| yield a }
      methods.each { |m| yield m }
      yield '}'
      yield "\n"
    end

    def hide_reverse_associations(attribute, klass_node)
      reverse_assocs = ast[attribute.type].children.each do |child_name, child_node|
        if child_node.is_a?(AttributeNode) &&
           child_node.type == klass_node.name &&
           child_node.association?

          attribute.reverse_association = child_node.collection? ? '0..*' : '0..1'
          child_node.visible = false
        end
      end
    end
  end
end
