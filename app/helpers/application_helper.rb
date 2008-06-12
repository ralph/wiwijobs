# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
      
  def status_icon
    @status_icon ||= { :expired => %w(orange close.gif), :pending => %w(yellow document.gif), :published => %w(green check.gif) }
  end
  
  def user_information_for(item)
    additional_text = (item.author != item.last_editor) ? ", zuletzt geändert von #{item.last_editor.name} am #{item.updated_at.to_s(:long)}" : ""
    content_tag "p", "Eingestellt von #{item.author.name} am #{item.created_at.to_s(:long)}#{additional_text}."
  end
  
  def menu_builder_for(user)
    if "Student" == user[:type]:
      [ {:label => "Startseite", :submenu_items => [link_to("Startseite", admin_path)]},
        {:label => "Fachschaftler", :submenu_items => [
          link_to("Profil", user_path(user)),
          (link_to("Benutzer", users_path) if user.has_right?("users", "update_all")),
          link_to("FS-Listen", students_users_path)]},
        {:label => "FS-Seite", :submenu_items => [
          link_to("News", news_items_path),
          link_to("Links", admin_path)]},
        {:label => "Praktikumsbörse", :submenu_items => [
          link_to("Angebote", jobs_path),
          link_to("Veranstaltungen", job_events_path),
          link_to("Links", job_links_path)]},
        {:label => "Externe Systeme", :submenu_items => [
          link_to("Fotos", "http://www.wi.uni-muenster.de/FS/admin/fotos/"),
          link_to("Dokumente", "http://www.wiwi.uni-muenster.de/bscw/"),
          link_to("Listserv WI-AG", "http://listserv.uni-muenster.de/mailman/admin/wi-ag"),
          link_to("Listserv FS-WiWi", "http://listserv.uni-muenster.de/mailman/admin/fs-wiwi")]}
      ]
    elsif ("Faculty" == user[:type]) or ("Company" == user[:type]):
      [ {:label => "Startseite", :submenu_items => [link_to("Startseite", admin_path)]},
        {:label => "Profil", :submenu_items => [link_to("Profil", user_path(user))]},
        {:label => "Praktikumsbörse", :submenu_items => [link_to("Praktikumsbörse", jobs_path)]}
      ]
    else
      [ {:label => "Start", :submenu_items => [link_to("Startseite", index_path)]} ]
    end
  end
  
  def lightwindow_include_tag
    unless @lightwindow_included:
      content_for(:head) do
        r = []
        r << stylesheet_link_tag('lightwindow', :media => "screen, projection")
        r << javascript_include_tag("lightwindow")
        r.join("\n")
      end
      @lightwindow_included = true
    end
  end
  
  def flash_notice_via_rjs(notice)
    update_page do |page|
      page['flash_notice'].replace_html ""
      page.insert_html :top, "flash_notice", notice
      page['flash_notice'].show
    end
  end
end
