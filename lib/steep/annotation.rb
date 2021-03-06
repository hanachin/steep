module Steep
  module Annotation
    class Base; end

    class VarType < Base
      attr_reader :var
      attr_reader :type

      def initialize(var:, type:)
        @var = var
        @type = type
      end

      def ==(other)
        other.is_a?(VarType) &&
          other.var == var &&
          other.type == type
      end
    end

    class MethodType < Base
      attr_reader :method
      attr_reader :type

      def initialize(method:, type:)
        @method = method
        @type = type
      end

      def ==(other)
        other.is_a?(MethodType) &&
          other.method == method &&
          other.type == type
      end
    end

    class ReturnType < Base
      attr_reader :type

      def initialize(type:)
        @type = type
      end

      def ==(other)
        other.is_a?(ReturnType) && other.type == type
      end
    end

    class BlockType < Base
      attr_reader :type

      def initialize(type:)
        @type = type
      end

      def ==(other)
        other.is_a?(BlockType) && other.type == type
      end
    end

    class SelfType < Base
      attr_reader :type

      def initialize(type:)
        @type = type
      end

      def ==(other)
        other.is_a?(SelfType) && other.type == type
      end
    end

    class InstanceType < Base
      attr_reader :type

      def initialize(type:)
        @type = type
      end

      def ==(other)
        other.is_a?(InstanceType) && other.type == type
      end
    end

    class ModuleType < Base
      attr_reader :type

      def initialize(type:)
        @type = type
      end

      def ==(other)
        other.is_a?(ModuleType) && other.type == type
      end
    end

    class Implements < Base
      attr_reader :module_name

      def initialize(module_name:)
        @module_name = module_name
      end

      def ==(other)
        other.is_a?(Implements) && other.module_name == module_name
      end
    end

    class NameType < Base
      attr_reader :name
      attr_reader :type

      def initialize(name:, type:)
        @name = name
        @type = type
      end

      def ==(other)
        other.is_a?(self.class) && other.name == name && other.type == type
      end
    end

    class ConstType < NameType
    end

    class IvarType < NameType
    end

    class Dynamic < Base
      attr_reader :name

      def initialize(name:)
        @name = name
      end

      def ==(other)
        other.is_a?(Dynamic) && other.name == name
      end
    end

    class Collection
      attr_reader :var_types
      attr_reader :method_types
      attr_reader :annotations
      attr_reader :block_type
      attr_reader :return_type
      attr_reader :self_type
      attr_reader :const_types
      attr_reader :instance_type
      attr_reader :module_type
      attr_reader :implement_module
      attr_reader :ivar_types
      attr_reader :dynamics

      def initialize(annotations:)
        @var_types = {}
        @method_types = {}
        @const_types = {}
        @ivar_types = {}
        @dynamics = Set.new

        annotations.each do |annotation|
          case annotation
          when VarType
            var_types[annotation.var] = annotation
          when MethodType
            method_types[annotation.method] = annotation
          when BlockType
            @block_type = annotation.type
          when ReturnType
            @return_type = annotation.type
          when SelfType
            @self_type = annotation.type
          when ConstType
            @const_types[annotation.name] = annotation.type
          when InstanceType
            @instance_type = annotation.type
          when ModuleType
            @module_type = annotation.type
          when Implements
            @implement_module = annotation.module_name
          when IvarType
            ivar_types[annotation.name] = annotation.type
          when Dynamic
            dynamics << annotation.name
          else
            raise "Unexpected annotation: #{annotation.inspect}"
          end
        end

        @annotations = annotations
      end

      def lookup_var_type(name)
        var_types[name]&.type
      end

      def lookup_method_type(name)
        method_types[name]&.type
      end

      def lookup_const_type(node)
        const_types[node]
      end

      def +(other)
        self.class.new(annotations: annotations.reject {|a| a.is_a?(BlockType) } + other.annotations)
      end

      def any?(&block)
        annotations.any?(&block)
      end

      def size
        annotations.size
      end

      def include?(obj)
        annotations.include?(obj)
      end
    end
  end
end
