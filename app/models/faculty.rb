class Faculty < User
  attr_accessible :institution_name, :contact_person_name
  validates_presence_of :institution_name
  localized_names "Der Fakultäts-Benutzer",
    :institution_name => "Der Fakultäts-Name",
    :login => "Der Benutzername",
    :email => "Die E-Mail-Adresse", 
    :password => "Das Passwort", 
    :password_confirmation => "Die Passwort-Bestätigung"
  
  def name
    institution_name
  end
end
