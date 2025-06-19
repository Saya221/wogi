# frozen_string_literal: true

class Api::V1::Client::ReportsController < Api::V1::Client::BaseController
  def index
    render_json Api::V1::Client::ReportsService.new(client: current_user).call
  end

  private

  def permit_params; end
end
