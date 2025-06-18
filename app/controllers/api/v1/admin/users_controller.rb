# frozen_string_literal: true

class Api::V1::Admin::UsersController < Api::V1::Admin::BaseController
  include Api::V1::PermitParams

  def index
    pagy_info, records = paginate users

    render_json records, meta: { pagy_info: }
  end

  def show
    user = users.find(params[:id])

    render_json user
  end

  def create
    user = Client.create!(user_params)

    render_json user
  end

  private

  def users
    @users ||= User.filter_by(params[:filter].to_h).conditions_sort(params[:sort].to_h)
  end

  def user_params
    params.require(:user).permit(:email, :password, :name, :payout_rate)
  end
end
