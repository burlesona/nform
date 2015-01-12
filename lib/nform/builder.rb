require 'active_support/core_ext/string'

module NForm
  class Builder
    include HTML

    attr_reader :object
    def initialize(object,id: nil, action: nil, method: nil)
      @object = object
      @form_id = id
      @action = action
      @method = method
    end

    def form_id
      @form_id || object_name.dasherize
    end

    def action
      @action or
      "/#{collection_name.dasherize}" + (new_object? ? "" : "/#{object.id}")
    end

    def method
      @method || (new_object? ? "POST" : "PATCH")
    end

    def new_object?
      @object.is_a?(Symbol) || object.new?
    end

    def object_name
      if object.is_a?(Symbol)
        object.to_s
      else
        object.class.name.demodulize.underscore
      end
    end

    def collection_name
      object_name.pluralize
    end

    def method_tag
      tag(:input, type:"hidden", name:"_method", value:method) if method != "POST"
    end

    def render
      tag(:form, id: form_id, action:action, method:"POST") do
        body = yield(self) if block_given?
        njoin(method_tag,body)
      end
    end

    def title
      sjoin (new_object? ? "Create" : "Edit"), object_name.titleize
    end

    def param(*args)
      object_name + args.map{|a|"[#{a}]"}.join
    end

    def label_for(k, text: nil)
      tag(:label, for: k.to_s.dasherize){ text || k.to_s.titleize }
    end

    def input_for(k, type: "text", default: nil)
      val = object.send(k) || default
      tag(:input, type:type, id:k.to_s.dasherize, name:param(k), value:val)
    end

    def text_field(k, label: nil, default: nil)
      njoin label_for(k,text:label), input_for(k,default:default)
    end

    def hidden_field(k)
      input_for(k, type: "hidden")
    end

    def text_area(k, label: nil, default: nil)
      val = object.send(k) || default
      njoin(
        label_for(k, text:label),
        tag(:textarea, id:k.to_s.dasherize, name:param(k)){ "\n#{val}\n" if val }
      )
    end

    def select(k, options:, label: nil)
      njoin(
        label_for(k, text: label),
        tag(:select, id:k.to_s.dasherize, name:param(k)){
          njoin options.map{|k,v| tag(:option, value: k){v ? v : k}}
        }
      )
    end

    def association_select(association,key_method: :id, label_method: :name)
      label = detect_association_name(association)
      key = (label.downcase + "_id").to_sym
      options = Hash[ association.map{|i| [i.send(key_method), i.send(label_method)]}]
      select(key,options: options, label: label)
    end

    def date_input(k, label: nil, start_year: nil, end_year: nil, default:{})
      start_year ||= Date.today.year
      end_year ||= start_year+20
      val = get_value(object,k)
      tag :div, class: "date-input" do
        njoin label_for(nil,text:(label||k.to_s.titleize)),
              tag(:input, date_attrs(k,:month,"MM",01,12,get_value(val,:month, default[:month]))),
              tag(:input, date_attrs(k,:day,"DD",01,31,get_value(val,:day, default[:day]))),
              tag(:input, date_attrs(k,:year,"YYYY",start_year,end_year,get_value(val,:year, default[:year])))
      end
    end

    def date_attrs(k,time,ph,min,max,val)
      { class: "date-#{time}", type: "number", name: param(k,time),
        placeholder: ph, min: min, max: max, step: 1, value: val }
    end

    def submit_button
      tag(:button){new_object? ? "Create" : "Save"}
    end

    private
    def detect_association_name(assoc)
      if assoc.respond_to?(:name)
        assoc.name.demodulize
      elsif assoc.respond_to?(:model)
        assoc.model.name.demodulize
      elsif assoc.is_a?(Enumerable)
        assoc.first.class.name.demodulize
      else
        raise BuilderError, "Unable to determine association name"
      end
    end

    def get_value(object,key,default=nil)
      if object.nil?
        nil
      elsif object.respond_to?(key)
        object.send(key)
      elsif object.respond_to? :fetch
        object.fetch(key,nil)
      else
        raise BuilderError, "Undefined object method: #{key}"
      end or default
    end
  end

  class BuilderError < Error
  end
end
