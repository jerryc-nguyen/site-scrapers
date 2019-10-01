class ParsersController < ActionController::Base
  def details
    url = params[:url].split("?").first
    data = ItemParsers::Detail.by_url(url)
    if data.present?
      render json: { status: 200, data:  data }
    else
      render json: { status: 404, message: 'Not found!' }
    end
  end
end
