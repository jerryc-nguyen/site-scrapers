class ItemParsers::Detail
  def self.by_url(url)
    data = parser_for(url.split('?').first)&.detail
    data[:image_url] = data[:images_str].try(:first).to_s if data

    data
  end

  private

  def parser_for(url)
    if url.include?('tiki.vn')
      ItemParsers::Tiki.new(url)
    elsif url.include?('vinabook.com')
      ItemParsers::Vinabook.new(url)
    elsif url.include?('pibook.com')
      ItemParsers::Pibook.new(url)
    elsif url.include?('khaitam.com')
      ItemParsers::KhaiTam.new(url)
    elsif url.include?('nhanam.com.vn')
      ItemParsers::KhaiTam.new(url)
    elsif url.include?('nhanvan.com')
      ItemParsers::KhaiTam.new(url)
    elsif url.include?('sachphuongnam.com')
      ItemParsers::KhaiTam.new(url)
    else
      nil
    end
  end
end
