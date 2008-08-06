class UsersController < ApplicationController
  skip_before_filter :login_required, :check_authorization, :only => [ :activate, :reset_password ]
  layout "backend"
  
  # GET /users
  # GET /users.xml
  def index
    @filter = params[:filter]
    case @filter
    when "Student"
      @users = Student.find(:all)
    when "Faculty"
      @users = Faculty.find(:all)
    when "Company"
      @users = Company.find(:all)
    else
      @users = User.find(:all)
    end

    respond_to do |format|
      format.html # index.rhtml
      format.js
      format.xml  { render :xml => @users.to_xml }
      format.csv do
        send_data CsvSystem.render(@users), :filename => "users.csv"
      end
    end
  end
  
  # GET /users;students
  # GET /users.xml;students
  def students
    @filter = params[:filter]
    case @filter
    when "bwlvwl"
      @users = Student.find(:all, :conditions => {:wi_ag_member => false})
    when "wi"
      @users = Student.find(:all, :conditions => {:wi_ag_member => true})
    when "current"
      @users = Student.find(:all, :conditions => {:opt_out_date => nil})
    when "former"
      @users = Student.find(:all, :conditions => "opt_out_date <= NOW()")
    else
      @users = Student.find(:all)
    end
      
    respond_to do |format|
      format.html # students.rhtml
      format.js
      format.xml  { render :xml => @users.to_xml }
      format.csv do 
        UsersController::CSV::Writer.generate(csv_string = "", ',') do |csv|
          csv << ["login","email"]
          @users.each { |user| csv << [user.login, user.email] }
        end
        send_data csv_string, :filename => "fachschaftler.csv"
      end
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    return if access_denied_for?(@user)

    respond_to do |format|
      format.html { render :action => "show" } # show.rhtml
      format.xml  { render :xml => @user.to_xml }
      format.vcf { send_data @user.to_vcard, :filename => "#{@user.name}.vcf" }
    end
  end

  def update_user_type_specific_fields
    @user_type = params[:type] if self.valid_type?(params[:type])
    @roles, @default_role = Role.available_roles_for(@user_type)
    @user ||= User.new
    @user.role = @default_role
  end

  # GET /users/new
  def new
    if params[:user_type] 
      @user_type=params[:user_type]
    else 
      @user_type="Student"
    end
    @roles, @default_role = Role.available_roles_for(@user_type)
    @user = User.new
    @user.role = @default_role
    @avatar = Avatar.new
  end

  # GET /users/1;edit
  def edit
    @user = User.find(params[:id])
    @roles, @default_role = Role.available_roles_for(@user[:type])
  end

  # POST /users
  # POST /users.xml
  def create
    @user_type = params[:type][:type] if self.valid_type?(params[:type][:type])
    @roles, @default_role = Role.available_roles_for(@user_type)
    case @user_type
    when "Student"
      @user = Student.new(params[:user])
    when "Faculty"
      @user = Faculty.new(params[:user])
    when "Company"
      @user = Company.new(params[:user])
    else
      @user = Student.new(params[:user])
    end
    (@avatar = @user.build_avatar(params[:avatar])) if !params[:avatar][:uploaded_data].blank?
    @user.activate if (params[:activate][:checked] == "1")
    respond_to do |format|
      if @user.save
        if @user.recently_activated?:
          UserNotifier.deliver_signup_notification(@user, request)
        else
          UserNotifier.deliver_activation_notification(@user, request)
        end
        #   self.current_user = @user
        flash[:notice] = 'Der Benutzer wurde angelegt.'
        format.html { redirect_to user_url(@user) }
        format.xml  { head :created, :location => user_url(@user) }
      else
        @user.avatar ? (@user.avatar = nil unless @user.avatar.valid?) :
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    return if access_denied_for?(@user)
    if defined?(params[:activate][:checked]):
      @user.activate if (params[:activate][:checked] == "1")
    end
    if defined?(params[:avatar][:uploaded_data]):
      if !params[:avatar][:uploaded_data].blank?:
        old_avatar_id = @user.avatar.id if @user.avatar
        (@avatar = @user.build_avatar(params[:avatar]))
      end
    end
    params[:user][:role_id] = @user.role.id unless current_user.has_right?("users", "update_all")
    respond_to do |format|
      if @user.update_attributes(params[:user])
        Avatar.find(old_avatar_id).destroy if old_avatar_id
        flash[:notice] = 'Die Benutzerdaten wurden aktualisiert.'
        format.html { redirect_to user_url(@user) }
        format.xml  { head :ok }
      else
        @roles, @default_role = Role.available_roles_for(@user[:type])
        @user.avatar = old_avatar_id ? Avatar.find(old_avatar_id) : nil        
        # @user.avatar = Avatar.find(old_avatar_id) if old_avatar_id
        # @user.avatar = nil unless @user.avatar.valid?
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    return if access_denied_for?(@user)
    @user.destroy

    respond_to do |format|
      flash[:notice] = 'Der Benutzer wurde gelöscht.'
      format.html { redirect_to users_url }
      format.xml  { head :ok }
    end
  end

  def activate
    self.current_user = User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.activated?
      current_user.activate
      flash[:notice] = "Ihr Zugangskonto wurde aktiviert. Sie wurden automatisch am System angemeldet."
    end
    redirect_back_or_default(admin_url)
  end
  
  def reset_password
    @user = User.find_by_email(params[:email])
    if @user.blank?:
      flash[:error] = "Keinen Benutzer mit dieser E-Mail-Adresse gefunden!"
    else
      @user.reset_password
      UserNotifier.deliver_reset_password(@user, request)
      flash[:notice] = "Das Paswort wurde zurückgesetzt. Bitte überprüfen Sie Ihr E-Mail-Postfach."
    end      
    redirect_to login_url
  end
  
  def homepage
    if "Student" == current_user[:type]:
      redirect_to internal_news_items_path
    elsif ("Faculty" == current_user[:type]) or ("Company" == current_user[:type]):
      redirect_to job_news_items_path
    else
      redirect_to index_path
    end
  end
  
  protected
  def valid_type?(type)
    (type == "Student") or (type == "Company") or (type == "Faculty")
  end

end
