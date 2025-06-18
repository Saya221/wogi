# frozen_string_literal: true

module Api
  module V1
    module PermitParams
      extend ActiveSupport::Concern

      included do
        before_action :permit_params, only: %i[index]

        def permit_params
          %i[filter sort].each do |key|
            if params[key].is_a?(ActionController::Parameters)
              params[key] = params[key].permit(*model.column_names)
            end
          end
        end

        private

        def model
          @model ||= controller_name.classify.constantize
        end
      end
    end
  end
end
