# frozen_string_literal: true

class Api::V1::Admin::ProductsController < Api::V1::Admin::BaseController
  def index
    pagy_info, records = paginate products

    render_json records, meta: { pagy_info: }
  end

  def show
    product = products.find(params[:id])

    render_json product
  end

  def create
    product = products.create!(product_params)

    render_json product
  end

  def update
    product.update!(product_params)

    render_json product
  end

  def destroy
    product.destroy!

    render_json data: {}, meta: {}
  end

  private

  def brand
    @brand ||= Brand.find(params[:brand_id])
  end

  def products
    @products ||= brand.products
                       .filter_by(params.dig(:filter, :field) => params.dig(:filter, :value))
                       .conditions_sort(params.dig(:sort, :field) => params.dig(:sort, :value))
  end

  def product
    @product ||= products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :brand_id, :state)
          .merge(filter: {}, sort: {})
  end
end
