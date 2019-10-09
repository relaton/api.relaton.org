class StandardFetcher
  attr_reader :code, :year, :standard_type, :document_number,
    :document_in_xml, :document_in_hash

  def initialize(code:, year: nil, **options)
    @year = year
    @options = options
    @code = code.upcase
  end

  def fetch
    build_standard_object(
      relaton.fetch(code.upcase, year&.to_s, options),
    )
  end

  def self.fetch_by(code:, year: nil, **options)
    new(options.merge(code: code, year: year)).fetch
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
      @year = @year || @document_in_hash["docid"]["id"].split(":").last

      self
    end
  end
end
