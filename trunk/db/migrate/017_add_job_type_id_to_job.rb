class AddJobTypeIdToJob < ActiveRecord::Migration
  def self.up
    add_column "jobs", "job_type_id", "integer" 
    
  end

  def self.down
  end
end
