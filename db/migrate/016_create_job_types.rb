class CreateJobTypes < ActiveRecord::Migration
  def self.up
    create_table :job_types do |t|
      t.string :title
      t.timestamps
    end
    
    JobType.create(:title => "Abschlussarbeit")
    JobType.create(:title => "Praktikum")
    JobType.create(:title => "Berufseinstieg")
    JobType.create(:title => "Nebenjob")
  end

  def self.down
    drop_table :job_types
  end
end
