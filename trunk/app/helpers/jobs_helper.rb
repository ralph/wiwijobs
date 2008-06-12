module JobsHelper
  def jobs_header_column(title, order_key)
    link_to title, {:action => "index", :order => order_key, :filter => @filter}, :title => "Nach #{title} sortieren"
  end
end
