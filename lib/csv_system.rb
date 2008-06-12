require 'csv'

class CsvSystem
  def self.render(users)
    CsvSystem::CSV::Writer.generate(csv_string = "", ',') do |csv|
      csv << ["login","email"]
      users.each { |user| csv << [user.login, user.email] }
    end
    csv_string
  end
end