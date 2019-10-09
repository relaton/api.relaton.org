class StandardFinder
  def initialize(code:, **attributes)
    @attributes = attributes.compact
    @attributes[:code] = normalize_code(code)
  end

  def find_or_fetch
    find_standard || fetch_standard
  end

  def self.find_or_fetch_by(code:, **attributes)
    new(code: code, **attributes).find_or_fetch
  end

  private

  attr_reader :attributes

  def normalize_code(code)
    code.gsub("  ", " ").strip.upcase
  end

  def find_standard
    Standard.where(attributes).order(year: :desc).take
  end

  def fetch_standard
    standard = StandardFetcher.fetch_by(attributes)

    if standard
      store_new_standard(standard)
    end
  end

  def store_new_standard(standard)
    Standard.create!(
      code: standard.code,
      year: standard.year,
      standard_type: standard.standard_type,
      document_number: standard.document_number,
      document_in_xml: standard.document_in_xml,
      document_in_json: standard.document_in_hash,
      expires_at: set_document_expiry_date(standard),
    )
  end

  def set_document_expiry_date(standard)
    if short_cached_standards.include?(standard.standard_type.upcase)
      5.days.from_now
    else
      15.days.from_now
    end
  end

  def short_cached_standards
    @short_cached_standards ||= ["ISO", "CHINESE STANDARD"]
  end
end
