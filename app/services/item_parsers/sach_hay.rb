class ItemParsers::SachHay

  def initialize(keyword)
    @mechanize = Mechanize.new
    @mechanize.read_timeout = 30
    @mechanize.user_agent_alias = 'Mac Safari'
    @page = @mechanize.get(keyword) rescue nil
  end

  def detail
    {
      # description: description,
      publisher: publisher.to_s.strip,
      pages_count: pages_count,
      size: size,
      weight: weight,
      price: price,
      cost_price: cost_price,
      published_at: published_at.to_s.strip
    }
  end

  def price
    if @page.present?
      @page.search("tr:nth-child(1) td:nth-child(2)").text.split("Giá bán:")[1].to_s.split("\r").first.to_i * 1000 rescue nil
    end
  end

  def cost_price
    if @page.present?
      @page.search("tr:nth-child(1) td:nth-child(2)").text.split("Giá bìa:")[1].to_s.split("\r").first.to_i * 1000 rescue nil
    end
  end

  def description
    if @page.present?
      description = @page.search("tr:nth-child(2) > td p").to_s.strip.gsub("Minh Khai", "")
    end
  end

  def weight
    if @page.present?
      @page.search("tr:nth-child(1) td:nth-child(2)").text.split("Trọng lượng:")[1].to_s.split("\r").first rescue nil
    end
  end

  def published_at
    if @page.present?
      @page.search("tr:nth-child(1) td:nth-child(2)").text.split("Xuất bản:")[1].to_s.split("\r").first rescue nil
    end
  end

  def publisher
    if @page.present?
      @page.search("tr:nth-child(1) td:nth-child(2)").text.split("NXB:")[1].to_s.split("\r").first rescue nil
    end
  end

  def pages_count
    if @page.present?
      pages_count = @page.search("tr:nth-child(1) td:nth-child(2)").text.split("Số trang:")[1].split("trang - khổ:")[0].strip rescue nil
    end
  end

  def size
    if @page.present?
      pages_count = @page.search("tr:nth-child(1) td:nth-child(2)").text.split("khổ:")[1].to_s.split("\r").first rescue nil
    end
  end

end
