atom_feed(:url => formatted_list_jobs_url(:atom)) do |feed|
  feed.title("Die aktuellsten Praktikumsangebote")
  feed.updated(@jobs.first ? @jobs.first.created_at : Time.now.utc)
  feed.link(:rel => "alternate", :type => "text/html", :href => list_jobs_url)
  
  for job in @jobs
    feed.entry(job) do |entry|
      entry.title(job.title)
      entry.content(job.description, :type => 'html')

      entry.author do |author|
        author.name(job.author.name)
        author.email(job.author.email)
      end
    end
  end
end