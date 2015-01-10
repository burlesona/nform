module NForm
  module Inflections
    def dasherize(input)
      input.to_s.tr('_','-')
    end

    def demodulize(input)
      input.to_s.split('::').last
    end

    def underscore(input)
      return input unless input =~ /[A-Z-]|::/
      input.to_s.gsub(/::/, '/')
        .gsub(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
        .gsub(/([a-z\d])([A-Z])/,'\1_\2')
        .tr("-", "_")
        .downcase
    end

    def pluralize(input)
      input=~/s$/ ? input.to_s : input.to_s+"s"
    end

    # convert _ and - to spaces, remove trailing _id
    def humanize(input)
      input.to_s.gsub(/[-_]id$/,"").gsub(/[-_]/," ")
    end

    def titleize(input)
      humanize(input).split(' ').map{|w| w.capitalize }.join(' ')
    end
  end
end
