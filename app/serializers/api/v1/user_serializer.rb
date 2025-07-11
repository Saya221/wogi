# frozen_string_literal: true

class Api::V1::UserSerializer < Api::V1::BaseSerializer
  attributes %i[id name email type state payout_rate created_at updated_at]

  def attributes(*attrs)
    super.slice(*fields_custom[:users])
  end

  def payout_rate
    return unless fields_custom[:users].include?(:payout_rate)

    object.payout_rate.to_f
  end

  def created_at
    object.created_at.to_i
  end

  def updated_at
    object.updated_at.to_i
  end

  ROOT = {
    users: %i[id name email type state created_at updated_at]
  }.freeze
end
