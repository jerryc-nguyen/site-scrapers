class ItemParsers::Lazada

  def initialize(keyword)
    @mechanize = Mechanize.new
    @mechanize.user_agent_alias = 'Mac Safari'
    @detail_url = keyword
  end

  def parsed_categories_for(page)
    categories_elems = []
    cate1 = page.search(".breadcrumb__list li a")[2].attr("href").split("/").last rescue nil
    categories_elems.push(cate1)
    cate2 = cate1 = page.search(".breadcrumb__list li a")[3].attr("href").split("/").last rescue nil
     categories_elems.push(cate2)
  end

  def description
    page = @mechanize.get(@detail_url) rescue nil
    if page.present?
      header = page.search("#productDetails .product-description__title").to_s
      thumb_html = page.search("#productDetails product-description__webyclip-thumbnails").to_s
      description = page.search("#productDetails .product-description__block").to_s
      description.gsub(header, "").gsub(thumb_html, "").gsub("\n", "<br />")
    end
  end

  def detail
    page = @mechanize.get(@detail_url) rescue nil
    if page.present?
      title = page.search("head meta[property='og:title']").attr("content").to_s rescue nil

      header = page.search("#productDetails .product-description__title").to_s
      thumb_html = page.search("#productDetails product-description__webyclip-thumbnails").to_s
      description = page.search("#productDetails .product-description__block").to_s
      description = description.gsub(header, "").gsub(thumb_html, "").gsub("\n", "<br />")

      price_ref = page.search("#special_price_box").text.sub(".","").to_i
      cost_price_ref = page.search("#price_box").text.sub(".","").to_i rescue nil
      image_urls_ref = []
      og_image = page.search("head meta[property='og:image']").attr("content").to_s
      image_urls_ref << og_image.correct_image_size if og_image.present?

      if image_urls_ref.empty?
        image_book = page.search(".itm-imageWrapper")[1].attr("data-sprite").to_s rescue nil
        image_urls_ref.push(image_book.correct_image_size)
      end

      rate_averave_ref = page.search(".c-rating-total__text-rating-average").text.to_f rescue nil
      rate_count_ref = page.search(".c-rating-total__text-total-review").text.to_i rescue nil

      categories = parsed_categories_for(page)
      currency_ref = page.search("#special_currency_box").text rescue nil

      sku          = nil
      isbn10       = nil
      isbn13       = nil
      company      = nil
      version      = nil
      publisher    = nil
      weight       = nil
      size         = nil
      author       = nil
      pages_count  = nil
      published_at = nil
      sample       = nil
      isbn         = nil
      cover_type   = nil

      wrap_tr_table = []
      page.search(".specification-table tr").each{|tr| wrap_tr_table.push(tr.text.strip)}

      wrap_tr_table.each do |item|
        value = item.split("\n")[1].strip
        sku          = value if item.to_s.include?("SKU")
        sample       = value if item.to_s.include?("Mẫu mã")
        isbn         = value if item.to_s.include?("ISBN/ISSN")
        version      = value if item.to_s.include?("Phiên bản")
        weight       = value if item.to_s.include?("Trọng lượng (KG)")
        size         = value if item.to_s.include?("Kích thước sản phẩm (D x R x C cm)")
        cover_type   = value if item.to_s.include?("Định dạng sách")
      end

      page.search(".prd-attributesList li").each do |li|
        author       = li.text.split(":")[1].strip if li.text.to_s.include?("Tác giả:")
        published_at = li.text.split(":")[1].strip if li.text.to_s.include?("Ngày phát hành:")
        pages_count  = li.text.split(":")[1].strip if li.text.to_s.include?("Số trang: 400")
      end

      publisher      = page.search(".prod_header_brand_action a")[0].text
      isbn_sample    = sample.to_s.split("-").last

      if isbn_sample.to_i.to_s == isbn_sample && isbn_sample.to_s.length == 13
        isbn13 = isbn_sample
      end

      images = image_urls_ref.compact.select(&:present?).take(2).map do |url|
        {
          id: -1,
          thumb_url: url.correct_image_size
        }
      end

      {
        author: author,
        name: title,
        isbn10: nil,
        isbn13: isbn13,
        barcode: isbn13,
        description: description,
        price: price_ref,
        cost_price: cost_price_ref,
        url: @detail_url,
        rating_average: rate_averave_ref,
        categories_str: categories,
        images_str: image_urls_ref,
        images: images,
        weight: weight,
        publisher: publisher,
        size: size,
        page_count: pages_count,
        last_fetched_at: Time.zone.now,
        should_fetch: false,
        images_count: image_urls_ref.count,
        categories_count: categories.count,
        rating_count: rate_count_ref,
        cover_type: cover_type,
        source: "lazada",
        is_lastest: false
      }

    end
  end

end
