class JobLinksController < ApplicationController
  layout "backend"
  skip_before_filter :login_required, :check_authorization, :only => [ :list ]

  # GET /job_links
  # GET /job_links.xml
  def index(render_options = {})
    @job_links = JobLink.find(:all, :order => "position")

    respond_to do |format|
      format.html { render render_options }
      format.xml  { render :xml => @job_links.to_xml }
    end
  end

  # GET /job_links;list
  # GET /job_links.xml;list
  def list
    index(:layout => "frontend")    
  end

  # GET /job_links/1
  # GET /job_links/1.xml
  def show
    @job_link = JobLink.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @job_link.to_xml }
    end
  end

  # GET /job_links/new
  def new
    @job_link = JobLink.new
  end

  # GET /job_links/1;edit
  def edit
    @job_link = JobLink.find(params[:id])
  end

  # POST /job_links
  # POST /job_links.xml
  def create
    @job_link = JobLink.new(params[:job_link])
    @job_link.author = User.find(session[:user])
    @job_link.last_editor = User.find(session[:user])

    respond_to do |format|
      if @job_link.save
        flash[:notice] = 'Der Link wurde erfolgreich angelegt.'
        format.html { redirect_to job_links_url }
        format.xml  { head :created, :location => job_links_url }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @job_link.errors.to_xml }
      end
    end
  end

  # PUT /job_links/1
  # PUT /job_links/1.xml
  def update
    @job_link = JobLink.find(params[:id])
    @job_link.last_editor = User.find(session[:user])

    respond_to do |format|
      if @job_link.update_attributes(params[:job_link])
        flash[:notice] = 'Der Link wurde aktualisiert.'
        format.html { redirect_to job_links_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @job_link.errors.to_xml }
      end
    end
  end

  # DELETE /job_links/1
  # DELETE /job_links/1.xml
  def destroy
    @job_link = JobLink.find(params[:id])
    @job_link.destroy

    respond_to do |format|
      flash[:notice] = 'Der Link wurde gelöscht.'
      format.html { redirect_to job_links_url }
      format.xml  { head :ok }
    end
  end
end
