class Standard < ApplicationRecord
  def self.find_or_fetch_by(code:, **attributes)
    attributes = attributes.merge(code: code)
    where(attributes).take || fetch_standard(attributes)
  end

  def self.fetch_standard(attributes)
    standard  = StandardFinder.find_by(attributes)

    if standard
      create!(
        code: standard.code,
        year: standard.year,
        standard_type: standard.standard_type,
        document_number: standard.document_number,
        document_in_xml: standard.document_in_xml,
        document_in_json: standard.document_in_hash,
      )
    end
  end
end
