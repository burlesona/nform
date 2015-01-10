module NForm
  # Helper Methods for generating HTML markup
  module HTML
    VOID_ELEMENTS = %i|area base br col embed hr img input keygen link meta param source track wbr|
    # Generate an HTML Tag
    def tag(name, attributes={}, &block)
      open = sjoin name, attrs(attributes)
      body = block.call if block_given?
      if VOID_ELEMENTS.include?(name.to_sym)
        raise BuilderError, "Void elements cannot have content" if body
        "<#{open}>"
      elsif body =~ /[<>]/
        "<#{open}>\n#{body}\n</#{name}>"
      else
        "<#{open}>#{body}</#{name}>"
      end
    end

    def attrs(hash={})
      hash.delete_if{|k,v| v.nil? || v == "" }
          .map{|k,v| %Q|#{attr_key(k)}="#{v}"| }
          .join(" ")
    end

    def attr_key(k)
      k.is_a?(Symbol) ? k.to_s.gsub("_","-") : k
    end

    def sjoin(*args)
      args.delete_if{|a| a.nil? || a == ""}.join(' ')
    end

    def njoin(*args)
      args.compact.join("\n")
    end
  end
end
