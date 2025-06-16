# frozen_string_literal: true

class Api::V1::ClientSerializer < Api::V1::UserSerializer
  ROOT = {
    users: %i[id name email state payout_rate created_at updated_at]
  }.freeze
end
