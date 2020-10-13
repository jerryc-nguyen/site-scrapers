class ItemParsers::Detail
  def self.by_url(url)
    url = url.split('?').first

    data = if url.include?('tiki.vn')
      ItemParsers::Tiki.new(url).detail
    elsif url.include?("vinabook.com")
      ItemParsers::Vinabook.new(url).detail
    elsif url.include?("pibook.com")
      ItemParsers::Pibook.new(url).detail
    elsif url.include?("khaitam.com")
      ItemParsers::KhaiTam.new(url).detail
    elsif url.include?("nhanam.com.vn")
      ItemParsers::KhaiTam.new(url).detail
    elsif url.include?("nhanvan.com")
      ItemParsers::KhaiTam.new(url).detail
    elsif url.include?("sachphuongnam.com")
      ItemParsers::KhaiTam.new(url).detail
    else
      nil
    end

    if data.present?
      data[:image_url] = data[:images_str].try(:first).to_s
    end

    data
  end
end
