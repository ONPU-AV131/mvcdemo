class CreateRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :records do |t|
      t.string :name
      t.string :email
      t.string :city
      t.string :country
      t.string :state
      t.string :url

      t.text :comments

      t.timestamps
    end
  end
end
