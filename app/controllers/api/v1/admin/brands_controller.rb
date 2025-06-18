# frozen_string_literal: true

class Api::V1::Admin::BrandsController < Api::V1::Admin::BaseController
  include Api::V1::PermitParams

  def index
    pagy_info, records = paginate brands

    render_json records, meta: { pagy_info: }
  end

  def show
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

    render_json({}, meta: {})
  end

  private

  def brands
    @brands ||= Brand.filter_by(params[:filter].to_h).conditions_sort(params[:sort].to_h)
  end

  def brand
    @brand ||= brands.find(params[:id])
  end

  def brand_params
    params.require(:brand).permit(:name, :description, :country, :state, :website_url)
  end
end
