class ToursController < ApplicationController
  def index
      tours = Tour.all.sort_by(&:created_at).reverse!
      render json: TourSerializer.new(tours).serialized_json, status: :ok
  end

  private

  def tour_params
      params.require(:tour).permit(
              :id,
              :name,
              :season,
              :start_date
          ) ||
      ActionController::Parameters.new
  end
end