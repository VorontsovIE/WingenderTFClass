module WingenderTFClass
  UniprotInfo = Struct.new(:uniprot_ac, :uniprot_id) do
    def self.from_string(line)
      uniprot_ac, uniprot_id = line.chomp.split("\t", 2)
      self.new(uniprot_ac, uniprot_id)
    end

    def self.each_in_file(filename, &block)
      File.readlines(filename).drop(1).map{|line| self.from_string(line) }.each(&block)
    end

    def self.uniprot_ac_list_by_id_from_file(filename)
      result = self.each_in_file(filename)
                  .group_by(&:uniprot_id)
                  .map{|uniprot_id, uniprots|
                    [uniprot_id, uniprots.map(&:uniprot_ac)]
                  }.to_h
      result.default_proc = ->(h,k){h[k] = [] }
      result
    end
  end
end
