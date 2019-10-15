class ItemParsers::Sachkhaitam

  def initialize(keyword)
    @mechanize = Mechanize.new
    @mechanize.read_timeout = 30
    @mechanize.user_agent_alias = 'Mac Safari'
    @detail_url = keyword
  end

  def detail
    page = @mechanize.get(@detail_url) rescue nil

    if page.present?
      title = page.search(".product-view .name").text rescue nil
      description = page.search(".product-description .product-description-wrap").to_s rescue nil
      image = "www.sachkhaitam.com" + page.search(".image-container .image .zimg").attr("src").text rescue nil
      cost_price = page.search(".price #old-price-1").text.split(" ")[0].strip.gsub(".", "").to_f rescue nil
      price = page.search(".price #product-price-1").text.split(" ")[0].strip.gsub(".", "").to_f rescue nil
      image_urls_ref = [image]
      categories = []
      page.search(".nav .itemcrumb").each do |category|
        categories.push(category.text)
      end
      categories.delete_at(0)
      author       = page.search(".product-view .divAuthor a").text

      company      = nil
      version      = nil
      publisher    = nil
      page_count   = nil
      weight       = nil
      size         = nil
      pages_count  = nil
      published_at = nil
      translator   = nil
      cover_type   = nil

      {
        author: author,
        name: title,
        description: description,
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
        published_at: published_at,
        company: company,
        publisher: publisher,
        images_count: image_urls_ref.try(:count),
        categories_count: categories.try(:count),
        translator: translator,
        cover_type: cover_type,
        source: "sachkhaitam",
        is_lastest: false
      }
    end
  end
end
