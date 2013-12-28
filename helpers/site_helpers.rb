module SiteHelpers

  def page_title
    title = "Big Bear Labs"
    if data.page.title
      title = "#{data.page.title} | #{title}"
    end
    title
  end
  
  def page_description
    if data.page.description
      description = data.page.description
    else
      description = "We work on products and client projects for iOS, Mac and Web platforms."
    end
    description
  end

end