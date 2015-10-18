require 'rake'
require 'rake/clean'

task default: 'WingenderTFClass'
desc 'Download Wingender TFClass ontology'
task 'WingenderTFClass' => ['WingenderTFClass:download_tfclass', 'WingenderTFClass:download_uniprot_id_ac_mapping']

desc 'Download Wingender ontology files'
task 'WingenderTFClass:download_tfclass' => ['WingenderTFClass:download_tfclass:human', 'WingenderTFClass:download_tfclass:mouse']
task 'WingenderTFClass:download_tfclass:human' => 'source_data/TFOntologies/TFClass_human.obo'
task 'WingenderTFClass:download_tfclass:mouse' => 'source_data/TFOntologies/TFClass_mouse.obo'

directory 'source_data'
directory 'source_data/uniprot_infos/'
directory 'source_data/TFOntologies/'

file 'source_data/TFClass_ontologies_temp.zip' => 'source_data' do
  sh 'wget', 'http://tfclass.bioinf.med.uni-goettingen.de/suplementary/TFClass_ontologies.zip', '-O', 'source_data/TFClass_ontologies_temp.zip'
end

file 'source_data/TFOntologies/TFClass_human.obo' => ['source_data/TFOntologies/', 'source_data/TFClass_ontologies_temp.zip'] do
  sh 'unzip', 'source_data/TFClass_ontologies_temp.zip', 'TFClass_human.obo', '-d', 'source_data/TFOntologies/'
end

file 'source_data/TFOntologies/TFClass_mouse.obo' => ['source_data/TFOntologies/', 'source_data/TFClass_ontologies_temp.zip'] do
  sh 'unzip', 'source_data/TFClass_ontologies_temp.zip', 'TFClass_mouse.obo', '-d', 'source_data/TFOntologies/'
end



desc 'Download Uniprot ID-AC mapping'
task 'WingenderTFClass:download_uniprot_id_ac_mapping'

{'human' => 'Homo sapiens', 'mouse' => 'Mus musculus'}.each do |organism, organism_official_name|
  task 'WingenderTFClass:download_uniprot_id_ac_mapping' => "source_data/uniprot_infos/#{organism}.tsv"
  file "source_data/uniprot_infos/#{organism}.tsv" => "source_data/uniprot_infos/#{organism}.tsv.gz" do
    sh 'gzip', '--decompress', "source_data/uniprot_infos/#{organism}.tsv.gz"
  end

  file "source_data/uniprot_infos/#{organism}.tsv.gz" => 'source_data/uniprot_infos/' do
    query = 'organism:"%{organism}"' % {organism: organism_official_name}
    columns = ['id', 'entry name' ] # id - is uniprot_ac; entry_name is uniprot_id. Orwell DB

    options = {
      sort: 'score',
      desc: '',
      compress: 'yes',
      query: query,
      fil: '',
      format: 'tab',
      force: 'yes',
      columns: columns.join(','),
    }
    options_str = options.map{|k,v| "#{k}=#{v}" }.join('&')

    sh 'wget', "http://www.uniprot.org/uniprot/?#{options_str}", '-O', "source_data/uniprot_infos/#{organism}.tsv.gz"
  end
end

CLEAN << 'source_data/uniprot_ID_to_AC.tsv.gz'
CLEAN << 'source_data/TFClass_ontologies_temp.zip'

CLOBBER << 'source_data/uniprot_ID_to_AC.tsv'
CLOBBER << 'source_data/TFOntologies/*'
