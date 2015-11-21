require_relative 'term'
require_relative '../local_paths'
module WingenderTFClass
  module OBO
    class TFClassification

      def self.by_species(species)
        case species.to_s.downcase
        when 'human'
          OBO::TFClassification.from_file(FilePaths::TFOntologyHuman)
        when 'mouse'
          OBO::TFClassification.from_file(FilePaths::TFOntologyMouse)
        else
          raise "Unknown species `#{species}`"
        end
      end

      # terms by ids
      def initialize()
        @terms_by_id = {}
        @children_by_id = Hash.new{|h,k| h[k] = [] }
        @terms_by_name = Hash.new{|h,k| h[k] = [] }
        # @terms_by_id.each{|term_id, term|
        #   @children_by_id[term.parent_id] << term  if term.parent_id
        # }
        self << Term.new(self, '', '', 'Root', '', nil, [], [])
      end

      def <<(term)
        raise "Duplicate id #{term.id}"  if @terms_by_id[term.id]
        @terms_by_id[term.id] = term
        @terms_by_name[term.name] << term
        @children_by_id[term.parent_id] << term  if term.parent_id
      end

      def self.from_file(filename)
        tf_ontology = self.new
        terms = File.readlines(filename)
          .map(&:chomp)
          .slice_before{|line|
            line.start_with?('[Term]')
          }.drop(1)
          .map{|enumerator|
             Term.from_line_array(tf_ontology, enumerator.to_a)
          }
        terms.each{|term|
          tf_ontology << term
        }
        tf_ontology
      end

      def term_by_name(name)
        @terms_by_name[name]
      end

      def term(term_id)
        @terms_by_id[term_id]
      end

      def children(term_id)
        @children_by_id[term_id]
      end

      def root
        term('')
      end

      def leaf?(term_id)
        raise "Term #{term_id} does not exist"  unless @terms_by_id[term_id]
        @children_by_id[term_id].empty?
      end

      def tf_groups(slice_deepness)
        @terms_by_id.each_value.select{|term|
          term.deepness >= slice_deepness && (!term.parent || term.parent.deepness < slice_deepness)
        }.map{|term|
          [term, term.subtree_nodes]
        }.to_h
      end
    end
  end
end
