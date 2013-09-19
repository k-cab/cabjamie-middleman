module BblHelpers
end

## this is now obsolete.

# NOTE could use tag helpers instead. http://middlemanapp.com/helpers/#toc_3
def el_if_present( data, role, html_el = role )
  content = data[role]

  if data[role]
    attrs = case html_el
    when :img
      return image_tag data[:img]
    when :subimg
      return image_tag data[:subimg]
    else
      {}
    end

    inner_el = el html_el, content, role, attrs
  end
end


def el( type, content, role, attr_map = {})
  classname = role.to_s.strip.downcase.gsub(' ', '-')  # TODO special chars
  attrs = attr_map.map do |k, v|
    k.to_s + '="' + v.to_s + '"'
  end .join ' ' 

  "<#{type} class='#{classname}' #{attrs}>#{content}</#{type}>"
end

