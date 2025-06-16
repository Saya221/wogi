# frozen_string_literal: true

class Api::V1::Admin::BrandsController < Api::V1::Admin::BaseController
  def index
    pagy_info, records = paginate brands

    render_json records, meta: { pagy_info: }
  end

  def show
    brand = brands.find(params[:id])

    render_json brand
  end

  def create
    brand = Brand.create!(brand_params)

    render_json brand
  end

  def update
    brand.update!(brand_params)

    render_json brand
  end

  def destroy
    brand.destroy!

    render_json data: {}, meta: {}
  end

  private

  def brands
    @brands ||= Brand.filter_by(params.dig(:filter, :field) => params.dig(:filter, :value))
                     .conditions_sort(params.dig(:sort, :field) => params.dig(:sort, :value))
  end

  def brand
    @brand ||= brands.find(params[:id])
  end

  def brand_params
    params.require(:brand).permit(:name, :description, :country, :state, :website_url)
          .merge(filter: {}, sort: {})
  end
end
