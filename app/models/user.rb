require 'digest/sha1'
class User < ActiveRecord::Base
  belongs_to :role
  has_many :joblinks, :foreign_key=>"author_id"
  has_many :joblinks_last_editor, :class_name => "Joblink", :foreign_key=>"last_editor_id"
  has_many :jobevents, :foreign_key=>"author_id"
  has_many :jobevents_last_editor, :class_name => "Jobevent", :foreign_key=>"last_editor_id"
  has_many :jobs, :foreign_key=>"author_id"
  has_many :jobs_last_editor, :class_name => "Job", :foreign_key=>"last_editor_id"
  has_many :news_items, :foreign_key=>"author_id"
  has_many :news_items_last_editor, :class_name => "NewsItem", :foreign_key=>"last_editor_id"
  has_one :avatar, :dependent => :destroy
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  attr_accessible :login, :password, :password_confirmation, :email, :activated_at, :activation_code, :role_id, :role, :street, :zip, :city, :phone, :homepage

  validates_associated :avatar
  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  # Die Hilfsmethode zum Überprüfen der Einmaligkeit funktioniert nur auf Subtypebene
  # (Student, Fakultät, Unternehmen). Deswegen wurde die eigene Methode validate geschrieben.
  # validates_uniqueness_of   :login, :case_sensitive => false
  # validates_uniqueness_of   :email, :case_sensitive => false
  validates_format_of       :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "muss korrekt sein.", :allow_nil => false

  before_save :encrypt_password
  before_create :make_activation_code 
  
  # Das Übersetzungs-Plugin hat ein Problem mit Vererbung, d.h. die folgenden Angaben müssen in allen abgeleiteten
  # Klassen wiederholt werden. Die Tests zicken sogar rum, wenn die Angaben hier drin stehen, deshalb sich sie erst
  # mal auskommentiert. - (rvdh)
  # localized_names "Der Benutzer",
  #   :login => "Der Benutzername",
  #   :email => "Die E-Mail-Adresse", 
  #   :password => "Das Passwort", 
  #   :password_confirmation => "Die Passwort-Bestätigung"
  
  def validate
    double_user = User.find_by_login(login)
    if double_user:
      errors.add(:login, "wird schon von einem anderen Benutzer verwendet.") unless self == double_user
    end
    double_user = User.find_by_email(email)
    if double_user:
      errors.add(:email, "wird schon von einem anderen Benutzer verwendet.") unless self == double_user
    end
  end

  # Activates the user in the database.
  def activate
    @activated = true
    self.attributes = {:activated_at => Time.now.utc, :activation_code => nil}
    save(false)
  end

  def activated?
    !! activation_code.nil?
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end 
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  def name
    self.login
  end
  
  # checks of a user has a specific right
  def has_right?(controller, action)
    self.role.rights.detect{|right| right.controller == controller and right.action == action}
  end
  
  # checks if a user may perform an action to a specific object
  def may?(action, object)
    controller = get_controller_name(object)
    if (action == "show"): required_right = "index"
    else required_right = action+"_all"
    end
    self.has_right?(controller, required_right) or (self.has_right?(controller, action) and (self == object.author))
  end

  def get_controller_name(object)
    controller = object.class.to_s.tableize
    controller = "users" if (["students", "faculties", "companies"].include?(controller))
    return controller
  end
  
  def author
    self
  end
  
  def to_vcard
    card = Vpim::Vcard::Maker.make2 do |maker|
      maker.add_name do |name|
        name.given = first_name
        name.family = last_name
      end

      maker.add_addr do |addr|
        addr.preferred = true
        addr.location = 'work'
        addr.street = street unless street.blank?
        addr.locality = city unless city.blank?
        addr.postalcode = zip.to_s unless zip.blank?
      end

      maker.add_addr do |addr|
        addr.location = 'home'
        addr.street = home_street unless home_street.blank?
        addr.locality = home_city unless home_city.blank?
        addr.postalcode = home_zip.to_s unless home_zip.blank?
      end

      maker.birthday = birthday unless birthday.blank?
      
      if avatar:
        maker.add_photo do |photo|
          photo.link = avatar.public_filename
        end

        maker.add_photo do |photo|
          photo.image = File.open("public/avatars/#{avatar.id}/#{avatar.filename}").read
          photo.type = avatar.content_type
        end
      end

      maker.add_tel(mobile) { |t| t.location = 'cell'; t.preferred = true } unless mobile.blank?
      maker.add_tel(phone) { |t| t.location = 'work' } unless phone.blank?
      maker.add_tel(home_phone) { |t| t.location = 'home' } unless home_phone.blank?

      maker.add_x_aim(icq.to_s) { |xaim| xaim.location = 'home' } unless icq.blank?

      maker.add_email(email) { |e| e.preferred = true }
      maker.add_url(homepage) unless homepage.blank?
    end

    card.to_s
  end
  
  def reset_password
    make_new_password
    @password_reset = true
    save(false)
  end
    
  def recently_reset_password?
    @password_reset
  end
  
  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end

    
    def make_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
    
    def make_new_password
      self.password = make_activation_code[0,8]
    end
        
end
