class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :article_id, :score
      t.string :content, :title
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
