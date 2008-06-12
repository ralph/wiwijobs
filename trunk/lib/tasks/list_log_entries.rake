desc "Enumerate all log entries"
task :log_entries do
  extract_log_entries_with(/(JOB|JOBEVENT|JOBLINK)(CREATE|UPDATE|DESTROY)/)
end

task :job_log_entries do
  extract_log_entries_with(/JOB(CREATE|UPDATE|DESTROY)/)
end

task :job_event_log_entries do
  extract_log_entries_with(/JOBEVENT(CREATE|UPDATE|DESTROY)/)
end

task :job_link_log_entries do
  extract_log_entries_with(/JOBLINK(CREATE|UPDATE|DESTROY)/)
end

def extract_log_entries_with(pattern)
  result = []
  log_file = File.new("#{RAILS_ROOT}/log/#{RAILS_ENV}.log")
  log_file.each {|line| result << line if line =~ pattern}
  puts result
end
