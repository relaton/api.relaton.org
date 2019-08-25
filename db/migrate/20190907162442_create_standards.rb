class CreateStandards < ActiveRecord::Migration[5.2]
  def change
    create_table :standards do |t|
      t.string :code, index: true
      t.integer :year
      t.string :document_number, index: true
      t.string :standard_type, limit: 50
      t.binary :document_in_xml, limit: 10.megabyte
      t.jsonb :document_in_json

      t.timestamps
    end
  end
end
