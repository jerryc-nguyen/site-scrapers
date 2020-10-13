class ItemParsers::Amazon

  def initialize(keyword)
    @detail_url = keyword
    @mechanize = Mechanize.new
    @mechanize.read_timeout = 30
  end

  def detail
    page = @mechanize.get(@detail_url)

    if page.present?
      title  = page.search('#productTitle').text rescue nil
      title  = page.search('#ebooksProductTitle').text if title.blank?
      author = page.search('.contributorNameID').text
      description    = page.search('#bookDescription_feature_div noscript').to_s
      image_urls_ref = []
      backImage  = page.search('img.backImage').attr('src').text rescue nil
      frontImage = page.search('img.frontImage').attr('src').text rescue nil
      image_urls_ref.push(frontImage)
      image_urls_ref.push(backImage)
      page.search('#imgThumbs .imageThumb img').each{ |img| image_urls_ref.push(img.attr('src').to_s)}
      rate_count_ref   = page.search('#reviewSummary .totalReviewCount').text.to_i
      rate_averave_ref = page.search('#reviewSummary .arp-rating-out-of-text').text.split(' ')[0].to_f
      description = description.force_encoding('iso8859-1').encode('utf-8')
      cost_price = page.search('.a-list-item .a-text-strike').text.to_s.gsub('$', '').to_f
    
      sku            = nil
      version        = nil
      publisher      = nil
      weight         = nil
      size           = nil
      pages_count    = nil
      price_ref      = nil
      cost_price_ref = nil
      categories     = nil
      published_at   = nil
      company        = nil
      language       = nil
      isbn10         = nil
      isbn13         = nil
      cover_type     = nil

      if page.search('#productTitle').text.present?
        page.search('#productDetailsTable .content ul li').each do |item|
          isbn13       = item.text.sub('ISBN-13:','').strip.gsub('-', '') if item.text.to_s.include?('ISBN-13')
          publisher    = item.text.sub('Publisher:','').strip.split(';').first if item.text.to_s.include?('Publisher')
          version      = item.text.sub('Series:','').strip if item.text.to_s.include?('Series')
          weight       = item.text.sub('Shipping Weight:','').split('(')[0].strip if item.text.to_s.include?('Shipping Weight')
          size         = item.text.sub('Product Dimensions:','').strip if item.text.to_s.include?('Product Dimensions')
          pages_count  = item.text.sub('Hardcover:','').strip if item.text.to_s.include?('Hardcover')
          pages_count  = item.text.sub('Paperback:','').strip if item.text.to_s.include?('Paperback')
          language     = item.text.sub('Language:','').strip if item.text.to_s.include?('Language')
          isbn10       = item.text.sub('ISBN-10:','').strip if item.text.to_s.include?('ISBN-10')
          cover_type   = item.text.to_s.include?('Hardcover') ? 'Hardcover' : 'Paperback'
          published_at = item.text.to_s.scan(/\((.+)\)/).flatten.first if item.text.to_s.include?('Publisher')
        end
      else
        page.search('#productDetailsTable .content ul li').each do |item|
          sku          = item.text.sub('ASIN:','').strip if item.text.to_s.include?('ASIN')
          publisher    = item.text.sub('Publisher:','').strip if item.text.to_s.include?('Publisher')
          size         = item.text.sub('File Size:','').strip if item.text.to_s.include?('File Size')
          pages_count  = item.text.sub('Print Length:','').strip if item.text.to_s.include?('Print Length')
          published_at = item.text.sub('Publication Date:','').strip if item.text.to_s.include?('Publication Date')
        end
      end

      images = image_urls_ref.compact.select(&:present?).take(2).map do |url|
        {
          id: -1,
          thumb_url: url
        }
      end

      sku = sku.to_s.gsub('-', '')

      {
        sku: sku,
        barcode: sku,
        isbn13: isbn13,
        isbn10: isbn10,
        language: language,
        name: title,
        url: @detail_url,
        price: price_ref,
        cost_price: cost_price,
        images: images,
        rate_averave: rate_averave_ref,
        rate_count: rate_count_ref,
        categories_str: categories,
        images_str: image_urls_ref,
        description: description,
        currency: '$',
        company: company,
        publisher: publisher,
        weight: weight,
        size: size,
        author: author,
        pages_count: pages_count,
        published_at: published_at,
        cover_type: cover_type,
        should_fetch: false,
        images_count: image_urls_ref.count,
        source: 'amazon',
        is_lastest: false
      }
    end

  end
end
