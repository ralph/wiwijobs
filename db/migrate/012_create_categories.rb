class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.column :title, :string
      t.column :parent_id, :integer
      t.column :position, :integer
      t.column :type, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_column :news_items, :category_id, :integer
    
    internal_news = NewsCategory.create(:title => "interne News")
    internal_news.children << NewsCategory.create(:title => "FS News")
    internal_news.children << NewsCategory.create(:title => "Job News")
    internal_news.children << NewsCategory.create(:title => "OFIS News")
    external_news = NewsCategory.create(:title => "externe News")
    external_news.children << NewsCategory.create(:title => "Allgemeines")
    external_news.children << NewsCategory.create(:title => "Grundstudium")
    external_news.children << NewsCategory.create(:title => "Hauptstudium BWL / VWL")
    external_news.children << NewsCategory.create(:title => "Hauptstudium WI")
    external_news.children << NewsCategory.create(:title => "Veranstaltungen / Tagungen")

    %w(Accounting Consulting Finance Hochschule IT Marketing\ &\ Vertrieb Kommunikation\ &\ PR sonstige\ Bereiche).each do |job_category_title|
      JobCategory.create(:title => job_category_title)
    end
    
    create_table :job_categories_jobs, :id => false do |t|
      t.column "job_id", :integer
      t.column "job_category_id", :integer
    end
    
  end

  def self.down
    drop_table :categories
    remove_column :news_items, :category_id
    drop_table :job_categories_jobs
  end
end
