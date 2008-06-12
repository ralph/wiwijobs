class NewsItemsController < ApplicationController
  layout "backend"
  
  # GET /news_items
  # GET /news_items.xml
  def index
    @news_items = NewsItem.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @news_items.to_xml }
    end
  end

  # GET /news_items/1
  # GET /news_items/1.xml
  def show
    @news_item = NewsItem.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @news_item.to_xml }
    end
  end

  # GET /news_items/new
  def new
    @news_item = NewsItem.new
    @news_item.published_until = 2.months.from_now
  end

  # GET /news_items/1;edit
  def edit
    @news_item = NewsItem.find(params[:id])
  end

  # POST /news_items
  # POST /news_items.xml
  def create
    @news_item = NewsItem.new(params[:news_item])
    @news_item.author = User.find(session[:user])
    @news_item.last_editor = User.find(session[:user])

    respond_to do |format|
      if @news_item.save
        flash[:notice] = 'Der News-Beitrag wurde erfolgreich erstellt.'
        format.html { redirect_to news_items_url }
        format.xml  { head :created, :location => news_item_url(@news_item) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @news_item.errors.to_xml }
      end
    end
  end

  # PUT /news_items/1
  # PUT /news_items/1.xml
  def update
    @news_item = NewsItem.find(params[:id])
    @news_item.last_editor = User.find(session[:user])

    respond_to do |format|
      if @news_item.update_attributes(params[:news_item])
        flash[:notice] = 'Der News-Beitrag wurde erfolgreich aktualisiert.'
        format.html { redirect_to news_items_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @news_item.errors.to_xml }
      end
    end
  end

  # DELETE /news_items/1
  # DELETE /news_items/1.xml
  def destroy
    @news_item = NewsItem.find(params[:id])
    @news_item.destroy

    respond_to do |format|
      format.html { redirect_to news_items_url }
      format.xml  { head :ok }
    end
  end
  
  # GET /news_items;internal
  # GET /news_items.xml;internal
  def internal
    @news_items = NewsCategory.find_by_title("interne News").news_items.find(:all, :order => "published_at DESC", :conditions => "published_until > NOW()", :limit => 5)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @news_items.to_xml }
    end
  end
  
  # GET /news_items;job
  # GET /news_items.xml;job
  def job
    @news_items = NewsCategory.find_by_title("Job News").news_items.find(:all, :order => "published_at DESC", :conditions => "published_until > NOW()", :limit => 5)

    respond_to do |format|
      format.html { render :action => "internal" }
      format.xml  { render :xml => @news_items.to_xml }
    end
  end
  
  # GET /news_items;list
  # GET /news_items.xml;list
  def list
    @news_items = NewsCategory.find_by_title("externe News").find(:all, :order => "published_at DESC", :conditions => "published_until > NOW()", :limit => 5)

    respond_to do |format|
      format.html { render :layout => "frontend"}
      format.xml  { render :xml => @news_items.to_xml }
    end
  end
end
