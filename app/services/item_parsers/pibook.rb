class ItemParsers::Pibook

  def initialize(keyword)
    @mechanize = Mechanize.new
    @mechanize.read_timeout = 30
    @mechanize.user_agent_alias = 'Mac Safari'
    @detail_url = keyword
  end

  def detail
    page = @mechanize.get(@detail_url) rescue nil

    if page.present?
      title = title = page.search("head meta[property='og:title']").attr("content").to_s rescue nil
      description = page.search(".gioithieus .dmabout").to_s.gsub(/href=\".+.\"/, "").gsub(/Mua sách online.+toàn quốc./, "").gsub(/Mua sách.+24h/, "") rescue nil
      image = page.search("head meta[property='og:image']").attr("content").to_s rescue nil
      image_urls_ref = [image]
      categories = page.search(".cont .tip1").text.split("/").map(&:strip).drop(2)
      categories.pop

      author       = nil
      translator   = nil
      company      = nil
      version      = nil
      publisher    = nil
      page_count   = nil
      weight       = nil
      size         = nil
      pages_count  = nil
      published_at = nil
      cover_type   = nil
      sku          = nil
      cost_price   = nil
      price        = nil

      page.search(".sachct .sachct2 .pilist5 li").each do |li|
        text_item    = li.text
        author       = text_item.split("Tác giả")[1].strip if text_item.include?("Tác giả")
        cost_price   = text_item.split("Giá bìa")[1].strip.chomp("₫").gsub(",","").to_f if text_item.include?("Giá bìa")
        price        = text_item.split("Tại Pibook")[1].strip.chomp("₫").gsub(",","").to_f if text_item.include?("Tại Pibook")
        company      = text_item.split("Nhà phát hành")[1].strip if text_item.include?("Nhà phát hành")
        publisher    = text_item.split("Nhà Xuất Bản")[1].strip if text_item.include?("Nhà Xuất Bản")
        page_count   = text_item.split("Số trang")[1].strip.to_i if text_item.include?("Số trang")
        published_at = text_item.split("Phát hành")[1].strip if text_item.include?("Phát hành")
        cover_type   = text_item.split("Định dạng bìa")[1].strip if text_item.include?("Định dạng bìa")
        weight       = text_item.split("Trọng lượng vận chuyển")[1].strip if text_item.include?("Trọng lượng vận chuyển")
        size         = text_item.split("Kích thước")[1].strip if text_item.include?("Kích thước")
      end

      images = image_urls_ref.compact.select(&:present?).take(2).map do |url|
        {
          id: -1,
          thumb_url: url.gsub("cache/200x200", "cache/600x800").gsub(/w\d+\/media/, "w900/media")
        }
      end

      {
        author: author,
        name: title,
        description: description,
        sku: sku,
        price: price,
        cost_price: cost_price,
        url: @detail_url,
        categories_str: categories.map(&:to_book_key),
        images_str: image_urls_ref,
        images: images,
        weight: weight,
        size: size,
        page_count: page_count,
        last_fetched_at: Time.zone.now,
        should_fetch: false,
        images_count: image_urls_ref.try(:count),
        categories_count: categories.try(:count),
        translator: translator,
        cover_type: cover_type,
        publisher: publisher,
        company: company,
        published_at: published_at,
        source: "pibook",
        is_lastest: false
      }
    end
  end

end
