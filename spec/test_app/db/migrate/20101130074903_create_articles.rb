class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string :title
      t.boolean :published, :default => false
      t.datetime :published_at
      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
