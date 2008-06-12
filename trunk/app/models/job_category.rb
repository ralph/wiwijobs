class JobCategory < Category
  has_and_belongs_to_many :jobs
  
  def title_with_number_of_jobs
    "#{title} (#{jobs.find_current_and_published.size} Angebote)"
  end
end
