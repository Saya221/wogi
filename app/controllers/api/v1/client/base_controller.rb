# frozen_string_literal: true

class Api::V1::Client::BaseController < Api::V1::BaseController
  before_action :authorize_client!

  private

  def authorize_client!
    raise Api::Error::ActionNotAllowed, nil unless current_role == Client.name
  end
end
