class Api::LocationsController < ApplicationController
  before_action :set_google_places_client, only: [:search]

  def search
    begin
      locations = fetch_locations_from_google
    rescue => e
      return render_error(:bad_request, e.message)
    end

    simplified_locations = locations.take(5).map do |location|
        address = location.formatted_address.gsub(/〒\d{3}-\d{4}\s*/, '')
      {
        name: location.name,
        address: address,
        latitude: location.lat,
        longitude: location.lng
      }
    end

    render json: { status: 200, message: simplified_locations }
  end
  
  private

  def set_google_places_client
    @client = GooglePlaces::Client.new(
      ENV['GOOGLE_API_KEY'])
  end

  def handle_google_places_error
    yield
  rescue GooglePlaces::OverQueryLimitError
    render_error(:too_many_requests, "クエリ上限に達しました")
  rescue GooglePlaces::RequestDeniedError
    render_error(:forbidden, "リクエストが拒否されました")
  rescue GooglePlaces::InvalidRequestError
    render_error(:bad_request, "無効なリクエストです")
  rescue GooglePlaces::NotFoundError
    render_error(:not_found, "該当する結果が見つかりません")
  rescue GooglePlaces::UnknownError
    render_error(:internal_server_error, "未知のエラーが発生しました")
  rescue => e
    render_error(:internal_server_error, "予期しないエラーが発生しました：#{e.message}")
  end

  def fetch_locations_from_google
    handle_google_places_error do
      locations = @client.spots_by_query(
        params[:address],
        language: 'ja'
      )
  
      raise "地点が見つかりません" if locations.blank?
  
      locations
    end
  end
end