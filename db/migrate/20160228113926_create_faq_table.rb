class CreateFaqTable < ActiveRecord::Migration
  def change
    create_table :faqs do |t|
      t.string :title
      t.text :body
      t.integer :priority, default: 0
      t.timestamps
    end
  end
end
