class ItemParsers::Fahasa

  def initialize(keyword, driver = nil)
    @driver = driver || Selenium::WebDriver.for(:phantomjs)
    @driver.get keyword
    @detail_url = keyword
  end

  def description
    @driver.find_element(css: "#product_tabs_description_contents").text.gsub("\n", "<br />") rescue nil
  end

  def detail
    title = @driver.find_element(css: ".product-view  h1").text rescue nil

    description = @driver.find_element(css: "#product_tabs_description_contents").text.gsub("\n", "<br />") rescue nil

    price_ref = @driver.find_element(css: ".special-price  .price").text rescue nil

    cost_price_ref = @driver.find_element(css: ".old-price  .price").text rescue nil

    image_urls_ref = []

    og_image = @driver.find_element(css: "head meta[property='og:image']").attribute("content").to_s rescue nil
    image_urls_ref.push(og_image.to_s.correct_image_size)

    rate_averave_ref = @driver.find_element(css: ".rating-box .rating").attribute("style").scan(/\d+/).first.to_f*5/100 rescue nil

    rate_count_ref = @driver.find_element(css: ".review-position").text.scan(/\d+/).first.to_i rescue nil

    categories = []

    @driver.find_elements(css: '#ves-breadcrumbs .breadcrumb li a').each do |x|
      categories.push(x.attribute("href").sub(".html","").split("/").last)
    end

    categories.shift

    currency_ref = "đ"

    # @driver.find_element(css: "#product_tabs_additional a").click

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
    isbn         = nil
    cover_type   = nil
    language     = nil
    translator   = nil

    wrap_tr_table = []
    @driver.find_elements(css: "#product-attribute-specs-table tr").each do |tr|
      value = tr.find_element(css: ".label").text + ":" + tr.find_element(css: ".data").text
      wrap_tr_table.push(value)
    end
    wrap_tr_table.each do |item|
      value = item.split(":")[1].strip
      isbn         = value.to_i if item.to_s.include?("Mã hàng")
      author       = value if item.to_s.include?("Tác giả")
      weight       = value if item.to_s.include?("Trọng lượng (gr)")
      publisher    = value if item.to_s.include?("NXB")
      company      = value if item.to_s.include?("Mã NCC")
      company      = value if item.to_s.include?("Tên Nhà Cung Cấp")
      published_at = value if item.to_s.include?("Năm XB")
      pages_count  = value if item.to_s.include?("Số trang")
      size         = value if item.to_s.include?("Kích thước (cm)")
      cover_type   = value if item.to_s.include?("Hình thức")
      language     = value if item.to_s.include?("Ngôn ngữ")
      translator   = value if item.to_s.include?("Người Dịch")
    end

    if isbn.to_s.length == 10
      isbn10     = isbn
    elsif isbn.to_s.length == 13
      isbn13     = isbn
    end


    images = image_urls_ref.compact.select(&:present?).take(2).map do |url|
      {
        id: -1,
        thumb_url: url.to_s.correct_image_size
      }
    end

    {
      author: author,
      name: title.titleize,
      isbn10: isbn10,
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
      company: company,
      size: size,
      page_count: pages_count,
      last_fetched_at: Time.zone.now,
      should_fetch: false,
      images_count: image_urls_ref.count,
      categories_count: categories.count,
      rating_count: rate_count_ref,
      cover_type: cover_type,
      language: language,
      translator: translator,
      published_at: published_at,
      source: "fahasa",
      is_lastest: false
    }
  end
end

