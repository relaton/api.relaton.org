class StandardSerializer < ActiveModel::Serializer
  attributes :id, :code, :type, :updated_at, :document

  def type
    object.standard_type&.upcase
  end

  def document
    {
      json: object.document_in_json,
      xml: object.document_in_xml.force_encoding("UTF-8"),
    }
  end
end
