# frozen_string_literal: true

class Api::V1::Admin::UsersController < Api::V1::Admin::BaseController
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
    @users ||= User.filter_by(params.dig(:filter, :field) => params.dig(:filter, :value))
                   .conditions_sort(params.dig(:sort, :field) => params.dig(:sort, :value))
  end

  def user_params
    params.require(:user).permit(:email, :password, :name, :payout_rate)
          .merge(filter: {}, sort: {})
  end
end
