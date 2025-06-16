# frozen_string_literal: true

class UserSession < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  belongs_to :user

  before_create :generate_unique_session_token

  private

  def generate_unique_session_token
    self.session_token = loop do
      token = SecureRandom.urlsafe_base64
      break token unless session_token_exists?(token)
    end
  end

  def session_token_exists?(token)
    self.class.unscoped.exists?(session_token: token)
  end
end
