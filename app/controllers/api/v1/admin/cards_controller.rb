# frozen_string_literal: true

class Api::V1::Admin::CardsController < Api::V1::Admin::BaseController
  include Api::V1::PermitParams

  before_action :check_card_state, only: %i[approved rejected]

  def index
    pagy_info, records = paginate cards

    render_json records, meta: { pagy_info: }
  end

  def approved
    ActiveRecord::Base.transaction do
      card.approved!
      card.update!(card_params)
      card.user.accessible_products.create! product: card.product
    end

    render_json card, serializer: Api::V1::CardSerializer, type: :approved_card
  end

  def rejected
    card.rejected!

    render_json card
  end

  private

  def cards
    @cards ||= Card.filter_by(params[:filter].to_h).conditions_sort(params[:sort].to_h)
                   .includes(:product, :user)
  end

  def card
    @card ||= cards.find(params[:id])
  end

  def check_card_state
    raise Api::Error::ControllerRuntimeError, :invalid_card_state unless card.issued?
  end

  def card_params
    params.require(:card).permit(:pin_code)
  end
end
