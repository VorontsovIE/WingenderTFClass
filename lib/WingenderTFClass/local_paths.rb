module WingenderTFClass
  module FilePaths
    TFOntologyHuman = File.absolute_path('source_data/TFOntologies/TFClass_human.obo', __dir__)
    TFOntologyMouse = File.absolute_path('source_data/TFOntologies/TFClass_mouse.obo', __dir__)

    UniprotHuman = File.absolute_path('source_data/uniprot_infos/human.tsv', __dir__)
    UniprotMouse = File.absolute_path('source_data/uniprot_infos/mouse.tsv', __dir__)
  end
end
