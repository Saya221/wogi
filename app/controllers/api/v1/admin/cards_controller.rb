# frozen_string_literal: true

class Api::V1::Admin::CardsController < Api::V1::Admin::BaseController
  before_action :check_card_state, only: %i[approved cancelled]

  def index
    pagy_info, records = paginate cards

    render_json records, meta: { pagy_info: }
  end

  def approved
    ActiveRecord::Base.transaction do
      card.approve!
      card.user.accessible_products.create! product: card.product
    end

    render_json card, serializer: Api::V1::CardSerializer, type: :approved_card
  end

  def cancelled
    card.cancelled!

    render_json card
  end

  private

  def cards
    @cards ||= Card.filter_by(params.dig(:filter, :field) => params.dig(:filter, :value))
                   .conditions_sort(params.dig(:sort, :field) => params.dig(:sort, :value))
                   .includes(:product, :user)
  end

  def card
    @card ||= cards.find(params[:id])
  end

  def card_params
    params.require(:card).permit(:user_id, :product_id, :state)
          .merge(filter: {}, sort: {})
  end

  def check_card_state
    raise Api::Error::ControllerRuntimeError, :invalid_card_state unless card.issued?
  end
end
