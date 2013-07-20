class CreatePayPhones < ActiveRecord::Migration
  def change
    create_table :pay_phones do |t|
      t.string :number
      t.string :neighborhood
      t.string :lat
      t.string :lon

      t.timestamps
    end
  end
end
