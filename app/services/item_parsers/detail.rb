class ItemParsers::Detail
  def self.by_url(url)
    data = {}
    url = url.split('?').first

    if data.present?
      data[:image_url] = data[:images_str].try(:first).to_s
    end

    data
  end
end
