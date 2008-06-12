module LoggerSystem
  def self.included(extended_class)
    extended_class.extend ClassMethods
  end
  
  module ClassMethods
    def acts_as_loggable
      after_create :log_create
      after_update :log_update
      after_destroy :log_destroy
      include LoggerSystem::InstanceMethods
    end
  end
  
  module InstanceMethods
    def log_create
      logger.info("#{self.class.to_s.upcase}CREATE #{Time.now.to_s}: Der Benutzer #{self.author.name} mit der ID #{self.author.id} hat das #{self.class.to_s}-Objekt #{self.title} mit der ID #{self.id} angelegt.")
    end

    def log_update
      logger.info("#{self.class.to_s.upcase}UPDATE #{Time.now.to_s}: Der Benutzer #{self.last_editor.name} mit der ID #{self.last_editor.id} hat das #{self.class.to_s}-Objekt #{self.title} mit der ID #{self.id} verändert.")
    end

    def log_destroy
      logger.info("#{self.class.to_s.upcase}DESTROY #{Time.now.to_s}: Der Benutzer #{self.last_editor.name} mit der ID #{self.last_editor.id} hat das #{self.class.to_s}-Objekt #{self.title} mit der ID #{self.id} gelöscht.")
    end
  end
end