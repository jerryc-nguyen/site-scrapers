class ItemParsers::Nhanam

  def initialize(keyword)
    @mechanize = Mechanize.new
    @mechanize.read_timeout = 30
    @mechanize.user_agent_alias = 'Mac Safari'
    @detail_url = keyword
  end

  def detail
    page = @mechanize.get(@detail_url) rescue nil

    if page.present?
      title = page.search(".bookdetail .info h1").text.strip rescue nil
      description = page.search(".bookdetailblockcontent").to_s rescue nil
      image = page.search("head meta[property='og:image']").attr("content").to_s rescue nil
      image_urls_ref = [image]
      cost_price   = page.search(".price .oldprice span").text.gsub(".","").chomp("đ").to_f rescue nil
      price        = page.search(".price  p:nth-child(2) span").text.gsub(".","").chomp("đ").to_f rescue nil

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
      isbn         = nil
      isbn10       = nil
      isbn13       = nil

      {
        author: author,
        name: title,
        description: description,
        sku: isbn,
        price: price,
        cost_price: cost_price,
        url: @detail_url,
        categories_str: nil,
        images_str: image_urls_ref,
        images: images,
        weight: weight,
        size: size,
        page_count: page_count,
        last_fetched_at: Time.zone.now,
        should_fetch: false,
        images_count: image_urls_ref.try(:count),
        categories_count: 0,
        translator: translator,
        cover_type: cover_type,
        publisher: publisher,
        company: "Nhã Nam",
        published_at: published_at,
        isbn10: isbn10,
        isbn13: isbn13,
        source: "nhanam",
        is_lastest: false
      }
    end
  end

end
