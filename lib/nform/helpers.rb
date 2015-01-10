module NForm
  module Helpers
    def form_view(*args)
      NForm::Builder.new(*args).render
    end
  end
end
