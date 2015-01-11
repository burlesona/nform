module NForm
  module Helpers
    def form_view(*args,&block)
      NForm::Builder.new(*args).render &block
    end
  end
end
