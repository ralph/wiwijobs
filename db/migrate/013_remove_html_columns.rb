class RemoveHtmlColumns < ActiveRecord::Migration
  def self.up
    remove_column(:job_events, :description_html)
    remove_column(:job_links, :description_html)
    remove_column(:jobs, :description_html)
    remove_column(:jobs, :contact_data_html)
    remove_column(:news_items, :text_html)
  end

  def self.down
    add_column(:job_events, :description_html, :text)
    add_column(:job_links, :description_html, :text)
    add_column(:jobs, :description_html, :text)
    add_column(:jobs, :contact_data_html, :text)
    add_column(:news_items, :text_html, :text)
  end
end
