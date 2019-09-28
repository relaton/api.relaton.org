class StandardSerializer < ActiveModel::Serializer
  attributes :type, :code, :document, :updated_at

  def type
    object.standard_type&.upcase
  end

  def document
    xml_document || object.document_in_json
  end

  private

  def xml_document
    if @instance_options[:format].try(:to_s).try(:downcase) == "xml"
      object.document_in_xml.force_encoding("UTF-8")
    end
  end
end
