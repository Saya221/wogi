# frozen_string_literal: true

class Api::V1::Client::CardsController < Api::V1::Client::BaseController
  include Api::V1::PermitParams

  before_action :check_card_state, only: %i[update destroy rejected]
  before_action :check_parameters, only: %i[activate_accessible_product]

  def index
    pagy_info, records = paginate cards

    render_json records, meta: { pagy_info: }
  end

  def show
    if card.issued? || card.rejected?
      render_json card
    else
      render_json card, serializer: Api::V1::CardSerializer, type: :approved_card
    end
  end

  def create
    card = current_user.cards.create!(card_params)

    render_json card
  end

  def update
    card.update!(card_params)

    render_json card
  end

  def destroy
    card.destroy!

    render_json card
  end

  def rejected
    card.rejected!

    render_json card
  end

  def activate_accessible_product
    render_json Api::V1::Client::ActivateAccessibleProductService.new(
      user: current_user,
      product: card.product,
      card: card,
      activation_code: params[:activation_code],
      pin_code: params[:pin_code],
    ).call
  end

  private

  def card_params
    params.require(:card).permit(:product_id)
  end

  def cards
    @cards ||= current_user.cards.filter_by(params[:filter].to_h)
                           .conditions_sort(params[:sort].to_h)
                           .includes(:product)
  end

  def card
    @card ||= cards.find(params[:id])
  end

  def check_card_state
    raise Api::Error::ControllerRuntimeError, :invalid_card_state unless card.issued?
  end

  def check_parameters
    return if params[:activation_code] && (card.pin_code.present? ? params[:pin_code] : true)

    raise ActionController::ParameterMissing, nil
  end
end
