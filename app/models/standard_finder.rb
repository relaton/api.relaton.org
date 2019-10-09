class StandardFinder
  attr_reader :code, :year, :standard_type, :document_number,
    :document_in_xml, :document_in_hash

  def initialize(code:, year: nil, **options)
    @year = year
    @options = options
    @code = code.upcase
  end

  def find
    build_standard_object(
      relaton.fetch(code.upcase, year&.to_s, options),
    )
  end

  def self.find_by(code:, year: nil, **options)
    new(options.merge(code: code, year: year)).find
  end

  private

  attr_reader :options

  def relaton
    @relaton ||= Relaton::Db.new(nil, nil)
  end

  def build_standard_object(document)
    if document
      @document_in_xml = document.to_xml
      @document_in_hash = document.to_hash
      @document_number = @document_in_hash["docnumber"]
      @standard_type = @document_in_hash["docid"]["type"]&.downcase

      self
    end
  end
end
