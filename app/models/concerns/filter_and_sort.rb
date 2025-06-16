# frozen_string_literal: true

module FilterAndSort
  extend ActiveSupport::Concern

  included do
    scope :filter_by, ->(conditions = {}) do
      return all unless conditions.is_a?(Hash)

      conditions.reduce(all) { |query, (key, value)| query.where(key => value) }
    end

    scope :conditions_sort, ->(conditions = {}) do
      default_sort = { updated_at: :desc }
      return order(default_sort) unless conditions.is_a?(Hash)

      key = conditions.keys.first&.to_sym
      direction = conditions.values.first&.to_sym
      key = key.in?(attribute_names.map(&:to_sym)) ? key : :updated_at
      direction = %i[asc desc].include?(direction) ? direction : :desc
      sort_hash = key == :updated_at ? { key => direction } : { key => direction }.merge(default_sort)
      order(sort_hash)
    end
  end
end
