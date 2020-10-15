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
      ItemParsers::Sachkhaitam.new(url)
    elsif url.include?('nhanam.com.vn')
      ItemParsers::Nhanam.new(url)
    elsif url.include?('nhanvan.com')
      ItemParsers::Nhanvan.new(url)
    elsif url.include?('sachphuongnam.com')
      ItemParsers::SachPhuongNam.new(url)
    elsif url.include?('vnexpress.net')
      ItemParsers::VnExpress.new(url)
    elsif url.include?('bookbuy.vn')
      ItemParsers::Bookbuy.new(url)
    elsif url.include?('nhasachviet.vn')
      ItemParsers::Nhasachvietvn.new(url)
    else
      nil
    end
  end
end
