class ItemParsers::Tiki

  def initialize(keyword)
    @mechanize = Mechanize.new
    @mechanize.read_timeout = 30
    @mechanize.user_agent_alias = 'Mac Safari'
    @detail_url = keyword
  end

  def detail
    page = @mechanize.get(@detail_url) rescue nil
    if page.present?
      title = page.search('#product-name').text.strip
      description = page.search('#gioi-thieu p').to_s

      price_ref = page.search('#span-price').text.gsub('.', '').to_f
      image_urls_ref = []
      cost_price_ref = page.search('#span-list-price').text.gsub('.', '').to_f

      og_image = page.search('head meta[property='og:image']').attr('content').to_s

      image_urls_ref << og_image if og_image.present? && image_urls_ref.empty?

      rate_averave_ref = page.search('div[itemprop='aggregateRating'] meta[itemprop='ratingValue']').attr('content').text.to_f rescue 0
      rate_count_ref = page.search('div[itemprop='aggregateRating'] meta[itemprop='ratingCount']').attr('content').text.to_i rescue 0
      categories_elems = page.search('.breadcrumb li a').select{|item| item.attr('href').to_s.scan(/\/c\d+/).any? }
      categories = categories_elems.map{|item| item.attr('href').split('/').second }

      sku          = page.search('#product-sku p').text.strip
      company      = nil
      version      = nil
      publisher    = nil
      weight       = nil
      size         = nil
      author       = nil
      pages_count  = nil
      published_at = nil
      translator   = nil
      cover_type   = nil

      page.search('#chi-tiet tr').each_with_index do |tr, index|
        tds          = tr.search('td')
        sku          = sku.presence || tds.last.text.strip if tds.first.text.to_s.include?('SKU')
        company      = tds.last.text.strip if tds.first.text.to_s.include?('Công ty phát hành')
        if company.blank?
          company    = tds.last.text.strip if tds.first.text.to_s.include?('Manufacturer')
        end
        publisher    = tds.last.text.strip if tds.first.text.to_s.include?('Nhà xuất bản')
        version      = tds.last.text.strip if tds.first.text.to_s.include?('Phiên bản')
        weight       = tds.last.text.strip if tds.first.text.to_s.include?('Trọng lượng')
        size         = tds.last.text.strip if tds.first.text.to_s.include?('Kích thước')
        author       = tds.last.text.strip if tds.first.text.to_s.include?('Tác giả')
        pages_count  = tds.last.text.strip.to_i if tds.first.text.to_s.include?('Số trang')
        published_at = tds.last.text.strip if tds.first.text.to_s.include?('Ngày xuất bản')
        translator   = tds.last.text.strip if tds.first.text.to_s.include?('Dịch Giả')
        cover_type   = tds.last.text.strip if tds.first.text.to_s.include?('Loại bìa')
      end

      images = image_urls_ref.compact.select(&:present?).take(2).map do |url|
        {
          id: -1,
          thumb_url: url.gsub('cache/200x200', 'cache/600x800').gsub(/w\d+\/media/, 'w900/media')
        }
      end

      isbn13 = sku

      {
        author: author,
        name: title,
        isbn13: isbn13,
        barcode: isbn13,
        company: company,
        publisher: publisher,
        version: version,
        published_at: published_at,
        description: description,
        price: price_ref,
        cost_price: cost_price_ref,
        url: @detail_url.split('?').first,
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
        translator: translator,
        cover_type: cover_type,
        source: 'tiki',
        is_lastest: false
      }
    end
  end

end
