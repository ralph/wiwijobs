class Student < User
  validates_presence_of :first_name, :last_name
  attr_accessible :first_name, :last_name, :home_street, :home_zip, :home_city, :home_phone, :mobile, :icq, :birthday, :application_date, :opt_out_date, :key_fs, :key_wi, :study_course, :wi_ag_member
  localized_names "Der Fachschafts-Benutzer",
    :first_name => "Der Vorname",
    :last_name => "Der Nachname",
    :login => "Der Benutzername",
    :email => "Die E-Mail-Adresse", 
    :password => "Das Passwort", 
    :password_confirmation => "Die Passwort-Bestätigung"
    
  
  def name
    # compact removes all the nil elements from the array
    [first_name, last_name].compact.join(' ')
  end
end
