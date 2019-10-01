class ItemParsers::Detail
  def self.by_url(url)
    url = url.split('?').first

    data = if url.include?('tiki.vn')
      ItemParsers::Tiki.new(url).detail
    elsif url.include?("vinabook.com")
      ItemParsers::Vinabook.new(url).detail
    else
      nil
    end

    if data.present?
      data[:image_url] = data[:images_str].try(:first).to_s
    end

    data
  end
end
