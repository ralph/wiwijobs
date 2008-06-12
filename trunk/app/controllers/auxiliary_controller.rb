class AuxiliaryController < ApplicationController
  def textilize
    begin
      require 'RedCloth'
    rescue LoadError
      nil
    end
    @text = RedCloth.new(params[:text]).to_html
    respond_to do |format|
      format.js
    end
  end
end
