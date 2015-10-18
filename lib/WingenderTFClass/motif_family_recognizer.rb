require_relative 'obo/tf_classification'
require_relative 'uniprot_info'

module WingenderTFClass
  module FilePaths
    TFOntologyHuman = File.absolute_path('source_data/TFOntologies/TFClass_human.obo', __dir__)
    TFOntologyMouse = File.absolute_path('source_data/TFOntologies/TFClass_mouse.obo', __dir__)

    UniprotHuman = File.absolute_path('source_data/uniprot_infos/human.tsv', __dir__)
    UniprotMouse = File.absolute_path('source_data/uniprot_infos/mouse.tsv', __dir__)
  end


  module ProteinFamilyRecognizers
    def self.by_uniprot_id(deepness:, tf_classification_filename:, uniprot_infos_filename:)
      tf_classification = OBO::TFClassification.from_file(tf_classification_filename)
      ByUniprotID.new(
        ByUniprotAC.new(tf_classification, deepness),
        UniprotInfo.uniprot_ac_list_by_id_from_file(uniprot_infos_filename)
      )
    end
    HumanAtLevel = Hash.new{|h, deepness|
      h[deepness] = self.by_uniprot_id(
        deepness: deepness,
        tf_classification_filename: FilePaths::TFOntologyHuman,
        uniprot_infos_filename: FilePaths::UniprotHuman,
      )
    }

    MouseAtLevel = Hash.new{|h, deepness|
      h[deepness] = self.by_uniprot_id(
        deepness: deepness,
        tf_classification_filename: FilePaths::TFOntologyMouse,
        uniprot_infos_filename: FilePaths::UniprotMouse,
      )
    }
    
    class ByUniprotAC
      def initialize(tf_classification, deepness)
        @deepness = deepness
        @tf_classification = tf_classification
      end

      def subtree_groups
        @subtree_groups ||= @tf_classification.tf_groups(@deepness)
      end

      private def subtree_root_by_uniprot_ac
        @subtree_root_by_uniprot_id ||= begin
          result = Hash.new{|h,k| h[k] = [] }

          subtree_groups.each{|group_root, group_leafs|
            group_leafs.flat_map(&:uniprot_ACs).uniq.each{|uniprot_ac|
              result[uniprot_ac] << group_root
            }
          }
          result
        end
      end

      # In most cases Uniprot refers the only leaf, but in some cases it refers several leafs in different subtrees.
      # So we return an array of subfamilies
      def subfamilies_by_uniprot_ac(uniprot_ac)
        subtree_root_by_uniprot_ac[uniprot_ac]
      end

      def subfamilies_by_multiple_uniprot_acs(uniprot_acs)
        uniprot_acs.flat_map{|uniprot_ac|
          subfamilies_by_uniprot_ac(uniprot_ac)
        }.uniq
      end
    end

    #########################

    class ByUniprotID
      def initialize(motif_family_recognizer_by_uniprot_ac, uniprot_acs_by_id)
        @motif_family_recognizer_by_uniprot_ac = motif_family_recognizer_by_uniprot_ac
        @uniprot_acs_by_id = uniprot_acs_by_id
      end

      # In most cases Uniprot refers the only leaf, but in some cases it refers several leafs in different subtrees.
      # So we return an array of subfamilies
      def subfamilies_by_uniprot_id(uniprot_id)
        uniprot_acs = @uniprot_acs_by_id[uniprot_id]
        @motif_family_recognizer_by_uniprot_ac.subfamilies_by_multiple_uniprot_acs( uniprot_acs )
      end

      def subfamilies_by_multiple_uniprot_ids(uniprot_ids)
        uniprot_ids.flat_map{|uniprot_id|
          subfamilies_by_uniprot_id(uniprot_id)
        }.uniq
      end
    end
  end
end
