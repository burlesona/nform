require 'nform/core_ext'
require 'active_support/core_ext/string'

module NForm
  class Builder
    include HTML

    attr_reader :object, :form_class
    def initialize(object, id: nil, form_class: nil, action: nil, method: nil)
      @object = object
      @form_id = id
      @form_class = form_class
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

    def base_errors
      if e = errors[:base]
        tag(:ul, class: 'base errors') do
          if e.respond_to?(:map)
            zjoin e.map{|m| base_error(m) }
          else
            base_error(e)
          end
        end
      end
    end

    def base_error(e)
      tag(:li){ e }
    end

    def render
      tag(:form, id: form_id, class: form_class, action:action, method:"POST") do
        body = yield(self) if block_given?
        zjoin(method_tag,base_errors,body)
      end
    end

    def title
      sjoin (new_object? ? "Create" : "Edit"), object_name.titleize
    end

    def param(*args)
      object_name + args.map{|a|"[#{a}]"}.join
    end

    # allow "label: false" to prevent label being generated so that function that call label_for
    # can all consistently omit the label when label value is given as false
    def label_for(k, label: nil)
      tag(:label, for: k.to_s.dasherize){ label || k.to_s.titleize } unless label == false
    end

    def input_for(k, type: "text", default: nil, **args)
      val = object.send(k) || default
      opts = {type:type, id:k.to_s.dasherize, name:param(k), value:val}.merge(args)
      tag(:input,opts)
    end

    def error_for(k)
      tag(:span, class: 'error'){ errors[k] } if errors[k]
    end

    def text_field(k, label: nil, default: nil, **args)
      zjoin label_for(k, label:label), input_for(k,default:default,**args), error_for(k)
    end

    def number_field(k, label: nil, default: nil, **args)
      opts = {type:'number', pattern: '\d*'}.merge(args)
      zjoin label_for(k, label:label), input_for(k,type:'number',default:default,**opts), error_for(k)
    end

    def password_field(k, label: nil, **args)
      zjoin label_for(k, label:label), input_for(k,type:"password",**args), error_for(k)
    end

    def hidden_field(k,**args)
      input_for(k, type: "hidden",**args)
    end

    def text_area(k, label: nil, default: nil,**args)
      val = object.send(k) || default
      zjoin(
        label_for(k, label:label),
        tag(:textarea, id:k.to_s.dasherize, name:param(k),**args){ "#{val}" if val },
        error_for(k)
      )
    end

    def bool_field(k, label: nil,**args)
      checked = ( !object.send(k) || object.send(k) == "false" ) ? false : true
      zjoin label_for(k, label: label),
            tag(:input, type:'hidden',name:param(k), value:"false"),
            tag(:input, type:'checkbox', id: k.to_s.dasherize, name:param(k), value:"true", checked:checked,**args),
            error_for(k)
    end

    def select(k, options:, label: nil, blank: true,**args)
      opts = options.map{|value,text| option_for(k,value,text) }
      opts.unshift option_for(k,nil,nil) if blank
      zjoin(
        label_for(k, label: label),
        tag(:select, id:k.to_s.dasherize, name:param(k), **args){
          zjoin opts
        },
        error_for(k)
      )
    end

    def option_for(k,value,text)
      opts = {value: value}
      opts[:selected] = true if object.send(k) == value
      tag(:option, opts){text ? text : value}
    end

    def association_select(association,key_method: :id, label_method: :name, label: nil, **args)
      aname = detect_object_name(association)
      key = (aname.underscore + "_id").to_sym
      options = Hash[ association.map{|i| [i.send(key_method), i.send(label_method)]}]

      unless label == false
        label ||= aname.underscore.titleize
      end

      select(key,options: options, label: label, **args)
    end

    def date_input(k, label: nil, start_year: nil, end_year: nil, default:{})
      start_year ||= Date.today.year
      end_year ||= start_year+20
      val = get_value(object,k)
      tag :div, class: "date-input" do
        zjoin label_for(nil,label:(label||k.to_s.titleize)),
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

    def submit_button(**args)
      text = args.delete(:text)
      tag(:button,**args){ text || (new_object? ? "Create" : "Save") }
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

  BuilderError = Class.new(Error)
end
