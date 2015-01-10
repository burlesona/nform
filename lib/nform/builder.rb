module NForm
  class Builder
    include Inflections
    include HTML

    attr_reader :object
    def initialize(object,id: nil, action: nil, method: nil)
      @object = object
      @form_id = id
      @action = action
      @method = method
    end

    def form_id
      @form_id || dasherize(object_name)
    end

    def action
      @action or
      "/#{dasherize(collection_name)}" + (new_object? ? "" : "/#{object.id}")
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
        underscore(demodulize(object.class.name))
      end
    end

    def collection_name
      pluralize(object_name)
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
      sjoin (new_object? ? "Create" : "Edit"), titleize(object_name)
    end

    def param(*args)
      object_name + args.map{|a|"[#{a}]"}.join
    end

    def label_for(k, text: nil)
      tag(:label, for: dasherize(k)){ text || titleize(k) }
    end

    def input_for(k, type: "text")
      tag(:input, type:type, id:dasherize(k), name:param(k), value:object.send(k))
    end

    def text_field(k)
      njoin label_for(k), input_for(k)
    end

    def hidden_field(k)
      input_for(k, type: "hidden")
    end

    def text_area(k)
      njoin(
        label_for(k),
        tag(:textarea, id:dasherize(k), name:param(k)){"\n#{object.send(k)}\n"}
      )
    end

    def select(k, options:, label: nil)
      njoin(
        label_for(k, text: label),
        tag(:select, id:dasherize(k), name:param(k)){
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

    def date_input(k, label: nil, start_year: nil, end_year: nil)
      start_year ||= Date.today.year
      end_year ||= start_year+20
      val = get_value(object,k)
      tag :div, class: "date-input" do
        njoin label_for(nil,text:(label||titleize(k))),
              tag(:input, date_attrs(k,:month,"MM",01,12,get_value(val,:month))),
              tag(:input, date_attrs(k,:day,"DD",01,31,get_value(val,:day))),
              tag(:input, date_attrs(k,:year,"YYYY",start_year,end_year,get_value(val,:year)))
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
        demodulize(assoc.name)
      elsif assoc.respond_to?(:model)
        demodulize(assoc.model.name)
      elsif assoc.is_a?(Enumerable)
        demodulize(assoc.first.class.name)
      else
        raise BuilderError, "Unable to determine association name"
      end
    end

    def get_value(object,key)
      if object.nil?
        nil
      elsif object.respond_to?(key)
        object.send(key)
      elsif object.respond_to? :fetch
        object.fetch(key,nil)
      else
        raise BuilderError, "Undefined object method: #{key}"
      end
    end
  end

  class BuilderError < Error
  end
end
