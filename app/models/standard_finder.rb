class StandardFinder
  attr_reader :code, :year, :standard_type, :document_number,
    :document_in_xml, :document_in_hash

  def initialize(code:, year: nil)
    @code = code
    @year = year
  end

  def find
    build_standard_object(
      standard_finder_klass.find(code, year),
    )
  end

  def self.find_by(code:, year: nil, **options)
    new(options.merge(code: code, year: year)).find
  end

  private

  def build_standard_object(document)
    if document
      @document_in_xml = document.to_xml
      @document_in_hash = document.to_hash
      @document_number = @document_in_hash["docnumber"]
      @standard_type = @document_in_hash["docid"]["type"]&.downcase

      self
    end
  end

  def standard_finder_klass
    @standard_finder_klass ||= Finders::KlassFinder.find(code)
  end
end
