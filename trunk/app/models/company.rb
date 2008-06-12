class Company < User
  attr_accessible :institution_name, :contact_person_name
  validates_presence_of :institution_name
  localized_names "Der Unternehmens-Benutzer",
    :institution_name => "Der Unternehmens-Name",
    :login => "Der Benutzername",
    :email => "Die E-Mail-Adresse", 
    :password => "Das Passwort", 
    :password_confirmation => "Die Passwort-Bestätigung"

  def name
    institution_name
  end
end
