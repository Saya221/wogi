# frozen_string_literal: true

class Api::V1::Admin::ReportsController < Api::V1::Admin::BaseController
  before_action :check_parameters, only: %i[index]

  def index
    render_json Api::V1::Admin::ReportsService.new(brand:, client:).call
  end

  private

  def permit_params
    params.permit(:brand_id, :client_id)
  end

  def check_parameters
    return if params[:brand_id] && params[:client_id]

    raise ActionController::ParameterMissing, nil
  end

  def brand
    @brand ||= Brand.find(params[:brand_id])
  end

  def client
    @client ||= Client.find(params[:client_id])
  end
end
