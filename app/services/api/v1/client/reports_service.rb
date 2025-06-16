# frozen_string_literal: true

class Api::V1::Client::ReportsService < Api::V1::BaseService
  def initialize(client)
    @client = client
  end

  def call
    {
      total_products: client_products.count,
      total_spends: client_products.sum(:price),
      total_cards: client_cards.count,
      total_issued_cards: client_cards.issued.count,
      total_approved_cards: client_cards.approved.count,
      total_cancelled_cards: client_cards.cancelled.count
    }
  end

  private

  attr_reader :client

  def client_products
    @client_products ||= client.products
  end

  def client_cards
    @client_cards ||= client.cards
  end
end
