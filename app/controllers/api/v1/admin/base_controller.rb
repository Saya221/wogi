# frozen_string_literal: true

class Api::V1::Admin::BaseController < Api::V1::BaseController
  before_action :authorize_admin!

  private

  def authorize_admin!
    raise Api::Error::ActionNotAllowed, nil unless current_role == Admin.name
  end
end
