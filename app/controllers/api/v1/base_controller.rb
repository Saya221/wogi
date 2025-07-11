# frozen_string_literal: true

class Api::V1::BaseController < ApplicationController
  include Api::V1::BaseConcern

  before_action :authenticate_request
  before_action :set_paper_trail_whodunnit
  before_action :permit_params, only: %i[index]

  private

  attr_reader :current_session, :current_user, :current_role

  def authenticate_request
    request_info = Api::V1::JwtProcessingService.new(access_token: load_jwt_token).decode

    @current_user = request_info[:current_user]
    @current_session = request_info[:current_session]
    @current_role = current_user.type
  end

  def load_jwt_token
    header = request.headers["HTTP_JWT_AUTHORIZATION"]
    raise Api::Error::UnauthorizedRequest, nil unless header.is_a?(String)

    jwt_authorization = header.split
    valid_token_type = jwt_authorization.first == "Bearer"
    jwt_token = jwt_authorization.last
    raise Api::Error::UnauthorizedRequest, nil unless valid_token_type && jwt_token.present?

    jwt_token
  end
end
