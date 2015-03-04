module NForm
  # Helper Methods for generating HTML markup
  module HTML
    VOID_ELEMENTS = %i|area base br col embed hr img input keygen link meta param source track wbr|
    BOOL_ATTRIBUTES = %i|allowfullscreen async autofocus autoplay checked compact controls declare default defaultchecked defaultmuted defaultselected defer disabled draggable enabled formnovalidate hidden indeterminate inert ismap itemscope loop multiple muted nohref noresize noshade novalidate nowrap open pauseonexit readonly required reversed scoped seamless selected sortable spellcheck translate truespeed typemustmatch visible|

    # Generate an HTML Tag
    def tag(name, attributes={}, &block)
      open = sjoin name, attrs(attributes)
      body = block.call if block_given?
      if VOID_ELEMENTS.include?(name.to_sym)
        raise BuilderError, "Void elements cannot have content" if body
        "<#{open}>"
      else
        "<#{open}>#{body}</#{name}>"
      end
    end

    def attrs(hash={})
      hash.delete_if{|k,v| v.nil? || v == "" }
          .map{|k,v| attr_string(k,v) }
          .compact
          .join(" ")
    end

    def attr_string(k,v)
      if BOOL_ATTRIBUTES.include?(k)
        attr_key(k) if v
      else
        %Q|#{attr_key(k)}="#{v}"|
      end
    end

    def attr_key(k)
      k.is_a?(Symbol) ? k.to_s.gsub("_","-") : k
    end

    def zjoin(*args)
      args.delete_if{|a| a.nil? || a == ""}.join('')
    end

    def sjoin(*args)
      args.delete_if{|a| a.nil? || a == ""}.join(' ')
    end

    def njoin(*args)
      args.delete_if{|a| a.nil? || a == ""}.join("\n")
    end
  end
end
