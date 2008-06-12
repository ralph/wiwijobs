class JobsController < ApplicationController
  include AttachableSystem
  layout "backend"
  skip_before_filter :login_required, :check_authorization, :only => [ :list, :show, :impressum, :contact ]
  before_filter :clean_params, :only => [:create, :update]

  # GET /jobs
  # GET /jobs.xml
  def index
    valid_sort_criteria = %w(title author_id published_until)
    order_option = valid_sort_criteria.include?(params[:order]) ? {:order => params[:order]} : {}
    @filter = params[:filter]
    case @filter
    when "expired"
      @jobs = Job.find_expired(order_option)
    when "current"
      @jobs = Job.find_current(order_option)
    when "unpublished"
      @jobs = Job.find_unpublished(order_option)
    when "own"
      @jobs = current_user.jobs.find_ordered(order_option)
    else
      @jobs = Job.find_ordered(order_option)
    end

    respond_to do |format|
      format.html # index.rhtml
      format.js
      format.xml  { render :xml => @jobs.to_xml }
    end
  end

  # GET /jobs;list
  # GET /jobs.xml;list
  def list
    params[:page] ||= 1
    if params[:category_id].blank?
      @jobs = Job.find_current_and_published.paginate(:page => params[:page], :per_page => 10)
    else
      @category = JobCategory.find(params[:category_id], :include => :jobs)
      @jobs = @category.jobs.find_current_and_published.paginate(:page => params[:page], :per_page => 10)
    end

    respond_to do |format|
      format.html { render :layout => "frontend" }
      format.js
      format.xml  { render :xml => @jobs.to_xml }
      format.atom { render :layout => false }
    end
  end

  # GET /jobs/1
  # GET /jobs/1.xml
  def show
    @job = Job.find(params[:id])

    respond_to do |format|
      format.html { render :layout => "frontend" } # show.rhtml
      format.xml  { render :xml => @job.to_xml }
    end
  end

  # GET /jobs/new
  def new
    @job = Job.new
    @job.set_default_values
    @attachment = Attachment.new
  end

  # GET /jobs/1;edit
  def edit
    @job = Job.find(params[:id])
  end

  # POST /jobs
  # POST /jobs.xml
  def create
    @job = Job.new(params[:job])
    @job.author = @job.last_editor = User.find(session[:user])
    build_attachment_for(@job)

    respond_to do |format|
      if @job.save
        flash[:notice] = 'Das Praktikumsangebot wurde angelegt.'
        format.html { redirect_to jobs_url }
        format.xml  { head :created, :location => jobs_url }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @job.errors.to_xml }
      end
    end
  end

  # PUT /jobs/1
  # PUT /jobs/1.xml
  def update
    @job = Job.find(params[:id])
    return if access_denied_for?(@job)
    @job.last_editor = User.find(session[:user])
    build_attachment_for(@job)

    respond_to do |format|
      if @job.update_attributes(params[:job])
        Attachment.delete_all_orphaned
        flash[:notice] = 'Das Praktikumsangebot wurde aktualisiert.'
        format.html { redirect_to jobs_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @job.errors.to_xml }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.xml
  def destroy
    @job = Job.find(params[:id])
    return if access_denied_for?(@job)
    @job.destroy

    respond_to do |format|
      format.html { redirect_to jobs_url }
      format.xml  { head :ok }
    end
  end

  # GET /jobs;impressum
  # GET /jobs.xml;impressum
  def impressum
    respond_to do |format|
      format.html { render :layout => "frontend" }
    end
  end

  # GET /jobs;contact
  # GET /jobs.xml;contact
  def contact
    respond_to do |format|
      format.html { render :layout => "frontend" }
    end
  end

  private
  def clean_params
    if (params[:job][:published] == "1"):
      params[:job].delete(:published) unless current_user.has_right?("jobs", "publish")
    end
  end
end
