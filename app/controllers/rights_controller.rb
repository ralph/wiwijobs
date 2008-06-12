class RightsController < ApplicationController
  # GET /rights
  # GET /rights.xml
  def index
    @rights = Right.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @rights.to_xml }
    end
  end

  # GET /rights/1
  # GET /rights/1.xml
  def show
    @right = Right.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @right.to_xml }
    end
  end

  # GET /rights/new
  def new
    @right = Right.new
  end

  # GET /rights/1;edit
  def edit
    @right = Right.find(params[:id])
  end

  # POST /rights
  # POST /rights.xml
  def create
    @right = Right.new(params[:right])

    respond_to do |format|
      if @right.save
        flash[:notice] = 'Right was successfully created.'
        format.html { redirect_to right_url(@right) }
        format.xml  { head :created, :location => right_url(@right) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @right.errors.to_xml }
      end
    end
  end

  # PUT /rights/1
  # PUT /rights/1.xml
  def update
    @right = Right.find(params[:id])

    respond_to do |format|
      if @right.update_attributes(params[:right])
        flash[:notice] = 'Right was successfully updated.'
        format.html { redirect_to right_url(@right) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @right.errors.to_xml }
      end
    end
  end

  # DELETE /rights/1
  # DELETE /rights/1.xml
  def destroy
    @right = Right.find(params[:id])
    @right.destroy

    respond_to do |format|
      format.html { redirect_to rights_url }
      format.xml  { head :ok }
    end
  end
end
