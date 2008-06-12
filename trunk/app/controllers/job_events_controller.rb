class JobEventsController < ApplicationController
  include AttachableSystem
  layout "backend"
  skip_before_filter :login_required, :check_authorization, :only => [ :list ]

  # GET /job_events
  # GET /job_events.xml
  def index
    @filter = params[:filter]
    case @filter
    when "expired"
      @job_events = JobEvent.find_expired
    when "current"
      @job_events = JobEvent.find_current
    else
      @job_events = JobEvent.find_ordered
    end
    
    respond_to do |format|
      format.html # index.rhtml
      format.js
      format.xml  { render :xml => @job_events.to_xml }
    end
  end
  
  # GET /job_events;list
  # GET /job_events.xml;list
  def list
    @job_events = JobEvent.find_current
    
    respond_to do |format|
      format.html { render :layout => "frontend" }
      format.xml  { render :xml => @job_events.to_xml }
    end
  end

  # GET /job_events/1
  # GET /job_events/1.xml
  def show
    @job_event = JobEvent.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @job_event.to_xml }
    end
  end

  # GET /job_events/new
  def new
    @job_event = JobEvent.new
    @job_event.description = "Weiteres siehe Anhang."
    @job_event.time = Time.now + 3.weeks
    @attachment = Attachment.new
  end

  # GET /job_events/1;edit
  def edit
    @job_event = JobEvent.find(params[:id])
  end

  # POST /job_events
  # POST /job_events.xml
  def create
    @job_event = JobEvent.new(params[:job_event])
    @job_event.author = User.find(session[:user])
    @job_event.last_editor = User.find(session[:user])
    build_attachment_for(@job_event)

    respond_to do |format|
      if @job_event.save
        flash[:notice] = 'Der Veranstaltungshinweis wurde angelegt.'
        format.html { redirect_to job_events_url }
        format.xml  { head :created, :location => job_events_url }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @job_event.errors.to_xml }
      end
    end
  end

  # PUT /job_events/1
  # PUT /job_events/1.xml
  def update
    @job_event = JobEvent.find(params[:id])
    @job_event.last_editor = User.find(session[:user])
    build_attachment_for(@job_event)

    respond_to do |format|
      if @job_event.update_attributes(params[:job_event])
        Attachment.delete_all_orphaned
        flash[:notice] = 'Der Veranstaltungshinweis wurde aktualisiert.'
        format.html { redirect_to job_events_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @job_event.errors.to_xml }
      end
    end
  end

  # DELETE /job_events/1
  # DELETE /job_events/1.xml
  def destroy
    @job_event = JobEvent.find(params[:id])
    @job_event.destroy

    respond_to do |format|
      flash[:notice] = 'Der Veranstaltungshinweis wurde gelöscht.'
      format.html { redirect_to job_events_url }
      format.xml  { head :ok }
    end
  end
end
