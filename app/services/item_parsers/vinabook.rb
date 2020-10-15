class ItemParsers::Vinabook

  def initialize(keyword)
    @mechanize = Mechanize.new { |agent|
      agent.open_timeout   = 30
      agent.read_timeout   = 30
      agent.idle_timeout   = 30
    }
    @mechanize.user_agent_alias = 'Mac Safari'
    @detail_url = keyword
  end

  def detail
    page = @mechanize.get(@detail_url) rescue nil
    if page.present?
      title = page.search("head meta[property='og:title']").attr("content").to_s rescue nil
      author = page.search('.full-description .box-author').to_s.strip
      desc = page.search('.full-description').to_s.strip
      description = desc.gsub(author, '').gsub('\n', '<br />')
      price_ref = page.search('.product-prices .price-num').first.text.gsub('.', '').to_i rescue nil
      cost_price_ref = page.search('.product-prices .strike .list-price').first.text.gsub('.', '').to_i rescue nil
      image_urls_ref = []
      image_book = page.search('.image-wrap img').attr('src').to_s rescue nil
      image_urls_ref.push(image_book)
      rate_averave_ref = page.search('.total-score[itemprop='ratingValue']').text.to_f
      rate_count_ref = page.search('span[itemprop='ratingCount']').text.to_i
      categories = []
      currency_ref = page.search('.product-prices .price-num').last.text rescue nil

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
      translator   = nil
      language     = nil
      cover_type   = nil

      page.search('.product-feature li').each_with_index do |li, index|
        sku          = li.text.scan(/\d+/).first if li.text.to_s.include?('Mã Sản phẩm')
        company      = li.search('a').text.strip if li.text.to_s.include?('Nhà phát hành')
        publisher    = li.search('span').text.strip if li.text.to_s.include?('Nhà xuất bản')
        version      = '1st'
        weight       = li.text.scan(/\d+.+/).first if li.text.to_s.include?('Khối lượng')
        size         = li.text.scan(/\d+.+\d+.+/).first if li.text.to_s.include?('Kích thước')
        author       = li.search('span').text.strip if li.text.to_s.include?('Tác giả')
        pages_count  = li.search('span').text.strip.to_i if li.text.to_s.include?('Số trang')
        published_at = li.text.split('Ngày phát hành:')[1].strip if li.text.to_s.include?('Ngày phát hành')
        cover_type   = li.text.split('Định dạng:')[1].strip if li.text.to_s.include?('Định dạng')
        language     = li.text.split('Ngôn ngữ:')[1].strip if li.text.to_s.include?('Ngôn ngữ')
        translator   = li.search('span').text.strip if li.text.to_s.include?('Người dịch')
      end

      images = image_urls_ref.compact.select(&:present?).take(2).map do |url|
        {
          id: -1,
          thumb_url: url
        }
      end

      if sku.to_s.length >= 13
        isbn13 = sku
      else
        isbn10 = sku
      end

      {
        author: author,
        name: title,
        isbn13: isbn13,
        isbn10: isbn10,
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
        size: size,
        page_count: pages_count,
        last_fetched_at: Time.zone.now,
        should_fetch: false,
        images_count: image_urls_ref.count,
        categories_count: categories.count,
        comments_count: 0,
        rating_count: rate_count_ref,
        company: company,
        publisher: publisher,
        published_at: published_at,
        version: version,
        cover_type: cover_type,
        language: language,
        translator: translator,
        source: 'vinabook',
        is_lastest: false
      }

    end
  end

end
