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
      title = page.search(".sachct .sachct2 h1").text rescue nil
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
