class CreateJobTypes < ActiveRecord::Migration
  def self.up
    create_table :job_types do |t|
      t.string :title
      t.timestamps
    end
    
    JobType.create(:title => "Praktika")
    JobType.create(:title => "Nebenjobs")
    JobType.create(:title => "Abschlussarbeiten")
    JobType.create(:title => "Berufseinstieg")
  end

  def self.down
    drop_table :job_types
  end
end
