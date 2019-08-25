module RelatonHelper
  def stub_relaton_document(code, year, options = {})
    require "relaton_iso"

    allow(RelatonIso::IsoBibliography).to receive(:get).
      with(code, year.to_s, options).
      and_return(relaton_fixture_file(code, year))
  end

  def relaton_fixture_file(code, year)
    filename = (code + ":" + year.to_s + ".xml").gsub(" ", "-")
    file_content = File.read(Rails.root.join("spec", "fixtures", filename))

    RelatonIsoBib::XMLParser.from_xml(file_content.to_s)
  end
end
