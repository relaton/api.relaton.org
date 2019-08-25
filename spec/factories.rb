FactoryBot.define do
  factory :standard do
    year { 2003 }
    code { "ISO 19115" }
    standard_type { "iso" }
    document_number { "19115" }

    trait :with_document do
      document_in_xml do
        File.read(Rails.root.join("spec", "fixtures", "ISO-19115:2003.xml"))
      end
    end
  end
end
