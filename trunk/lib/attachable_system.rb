module AttachableSystem
  private
  def build_attachment_for(objekt)
    unless params[:attachment].blank?:
      unless params[:attachment][:uploaded_data].blank?:
        (@attachment = objekt.build_attachment(params[:attachment]))
      end
    end
  end
end