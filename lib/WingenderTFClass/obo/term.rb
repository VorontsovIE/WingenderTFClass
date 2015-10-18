module WingenderTFClass
  module OBO
    Term = Struct.new(:ontology_tree, :id, :name, :subset, :definition, :parent_id, :uniprot_ACs, :other) do
      def self.from_line_array(ontology_tree, arr)
        id, name, subset, definition, parent_id = nil, nil, nil, nil, nil
        other = []
        uniprot_ACs = []

        arr.select{|line|
          line.match(/^\w+:/)
        }.each{|line|
          case line
          when /^id:/
            id = line[/^id: (?<data>.+)$/, :data]
          when /^name:/
            name = line[/^name: (?<data>.+)$/, :data]
          when /^subset:/
            subset = line[/^subset: (?<data>.+)$/, :data]
          when /^def:/
            definition = line[/^def: (?<data>.+)$/, :data]
          when /^is_a:/
            parent_id = line[/^is_a: (?<data>.+?) ! .+$/, :data]
          when /^xref: UNIPROT:/
            uniprot_ACs << line[/^xref: UNIPROT:(?<data>\w+)\b/, :data]
          else
            other << line
          end
        }

        self.new(ontology_tree, id, name, subset, definition, parent_id || '', uniprot_ACs, other)
      end

      def parent
        ontology_tree.term(parent_id)
      end

      def <=>(other)
        if self.id.split('.').first == '0' && other.id.split('.').first == '0' # unclassified vs unclassified
          id <=> other.id
        elsif !self.id.split('.').first == '0' && !other.id.split('.').first == '0' # classified vs classified
          id <=> other.id
        elsif self.id.split('.').first == '0' # classified vs unclassified
          1
        else
          -1
        end
      end

      def children
        ontology_tree.children(id)
      end

      def leaf?
        ontology_tree.leaf?(id)
      end

      # It can be different from number of ancestors
      def deepness
        id.split('.').size
      end

      def descendant_leafs
        leaf? ? [self] : children.flat_map(&:descendant_leafs)
      end

      def descendants
        children + children.flat_map(&:descendants)
      end

      def subtree_nodes
        [self] + children.flat_map(&:subtree_nodes)
      end

      def ancestors
        result = []
        term = self
        while term.parent
          term = term.parent
          result.unshift(term)
        end
        result
      end

      def level_name
        case deepness
        when 0
          'all TFs'
        when 1
          'superclass'
        when 2
          'class'
        when 3
          'family'
        when 4
          'subfamily'
        when 5
          'genus'
        when 6
          'species'
        end
      end

      def to_s
        "#{name}{#{id}}"
      end

      def inspect; to_s; end
    end
  end
end
