# frozen_string_literal: true

class Api::V1::Client::CardsController < Api::V1::Client::BaseController
  before_action :check_card_state, only: %i[update destroy cancelled]

  def index
    pagy_info, records = paginate cards

    render_json records, meta: { pagy_info: }
  end

  def show
    if card.issued? || card.cancelled?
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

  def cancelled
    card.cancelled!

    render_json card
  end

  private

  def card_params
    params.require(:card).permit(:product_id)
          .merge(filter: {}, sort: {})
  end

  def cards
    @cards ||= current_user.cards
                           .filter_by(params.dig(:filter, :field) => params.dig(:filter, :value))
                           .conditions_sort(params.dig(:sort, :field) => params.dig(:sort, :value))
                           .includes(:product)
  end

  def card
    @card ||= cards.find(params[:id])
  end

  def check_card_state
    raise Api::Error::ControllerRuntimeError, :invalid_card_state unless card.issued?
  end
end
