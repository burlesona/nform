require 'active_support/core_ext/string'

module NForm
  class Builder
    include HTML

    attr_reader :object
    def initialize(object,id: nil, action: nil, method: nil)
      @object = object
      @form_id = id
      @action = action
      @http_method = method
    end

    def form_id
      @form_id || object_name.dasherize
    end

    def action
      @action or
      "/#{collection_name.dasherize}" + (new_object? ? "" : "/#{object.id}")
    end

    def http_method
      @http_method || (new_object? ? "POST" : "PATCH")
    end

    def new_object?
      object.respond_to?(:new?) ? object.new? : true
    end

    def object_name
      @object_name || detect_object_name(object).underscore
    end

    def collection_name
      object_name.pluralize
    end

    def method_tag
      tag(:input, type:"hidden", name:"_method", value:http_method) if http_method != "POST"
    end

    def errors
      @errors = if object.respond_to?(:errors)
        object.errors
      else
        {}
      end
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

    def error_for(k)
      tag(:span, class: 'error'){ errors[k] } if errors[k]
    end

    def text_field(k, label: nil, default: nil)
      njoin label_for(k,text:label), input_for(k,default:default), error_for(k)
    end

    def hidden_field(k)
      input_for(k, type: "hidden")
    end

    def text_area(k, label: nil, default: nil)
      val = object.send(k) || default
      njoin(
        label_for(k, text:label),
        tag(:textarea, id:k.to_s.dasherize, name:param(k)){ "\n#{val}\n" if val },
        error_for(k)
      )
    end

    def select(k, options:, label: nil)
      njoin(
        label_for(k, text: label),
        tag(:select, id:k.to_s.dasherize, name:param(k)){
          njoin options.map{|value,text| option_for(k,value,text) }
        },
        error_for(k)
      )
    end

    def option_for(k,value,text)
      opts = {value: value}
      opts[:selected] = true if object.send(k) == value
      tag(:option, opts){text ? text : value}
    end

    def association_select(association,key_method: :id, label_method: :name)
      label = detect_object_name(association)
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
              tag(:input, date_attrs(k,:year,"YYYY",start_year,end_year,get_value(val,:year, default[:year]))),
              error_for(k)
      end
    end

    def date_attrs(k,time,ph,min,max,val)
      { class: "date-#{time}", type: "number", name: param(k,time),
        placeholder: ph, min: min, max: max, step: 1, value: val }
    end

    def submit_button
      tag(:button){ new_object? ? "Create" : "Save" }
    end

    private
    def detect_object_name(o)
      if o.is_a?(Symbol)
        o.to_s
      elsif o.is_a?(Class)
        o.name
      elsif o.respond_to?(:object_name)
        o.object_name
      elsif o.respond_to?(:model)
        o.model
      elsif o.is_a?(Enumerable)
        detect_object_name(o.first)
      else
        o.class
      end.to_s.demodulize
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
