class ItemParsers::Khangvietbook

  def initialize(keyword)
    @mechanize = Mechanize.new
    @mechanize.read_timeout = 30
    @mechanize.user_agent_alias = 'Mac Safari'
    @detail_url = keyword
  end

  def detail
    page = @mechanize.get(@detail_url) rescue nil

    if page.present?
      title = page.search("head meta[property='og:title']").attr("content").to_s rescue nil
      description = page.search("#sec_about_book").to_s rescue nil
      image = "https://khangvietbook.com.vn/" + page.search(".wrap_img_detail .sub_book img").attr("src").to_s rescue nil
      image_urls_ref = [image]
      cost_price   = page.search(".pricebook_bia").text.gsub(".","").chomp("đ").to_f rescue nil
      price        = page.search(".pricebook_ban").text.gsub(".","").chomp("đ").to_f rescue nil

      author       = nil
      sku          = nil
      version      = nil
      publisher    = nil
      page_count   = nil
      weight       = nil
      size         = nil
      pages_count  = nil
      published_at = nil
      cover_type   = nil
      isbn         = nil
      isbn10       = nil
      isbn13       = nil
      categories   = nil
      company      = nil
      translator   = page.search(".center_detail .p_book").detect{|x| x.text.include?("Người dịch:")}.text.gsub("Người dịch:","").strip rescue nil
      categories   = page.search("#breadcrumb").text.split("/").map(&:strip).drop(1)
      categories.pop

       page.search("#sec_info_book .info_book tr").each do |tr|
        text_item    = tr.text
        company      = text_item.split("Công ty phát hành")[1].strip if text_item.include?("Công ty phát hành")
        author       = text_item.split("Tác giả")[1].strip if text_item.include?("Tác giả")
        publisher    = text_item.split("Nhà xuất bản")[1].strip if text_item.include?("Nhà xuất bản")
        page_count   = text_item.split("Số trang")[1].strip.to_i if text_item.include?("Số trang")
        published_at = text_item.split("Ngày xuất bản")[1].strip if text_item.include?("Ngày xuất bản")
        size         = text_item.split("Kích thước")[1].strip if text_item.include?("Kích thước")
        sku          = text_item.split("SKU")[1].strip if text_item.include?("SKU")
        weight       = text_item.split("Trọng lượng")[1].strip if text_item.include?("Trọng lượng")
      end

      images = image_urls_ref.compact.select(&:present?).take(2).map do |url|
        {
          id: -1,
          thumb_url: url.gsub("cache/200x200", "cache/600x800").gsub(/w\d+\/media/, "w900/media")
        }
      end

      if sku.to_s.length >= 13
        isbn13 = sku
      elsif sku.to_s.length >= 10
        isbn10 = sku
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
        categories_count: categories.count,
        translator: translator,
        cover_type: cover_type,
        publisher: publisher,
        company: company,
        published_at: published_at,
        isbn10: isbn10,
        isbn13: isbn13,
        source: "khangvietbook"
      }
    end
  end

end
