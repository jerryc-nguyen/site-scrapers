class ItemParsers::VnExpress

  def initialize(url)
    @mechanize = Mechanize.new
    @mechanize.read_timeout = 30
    @mechanize.user_agent_alias = 'Mac Safari'
    @detail_url = url
  end

  def detail
    page = @mechanize.get(@detail_url)

    {
      title: content_for('title').to_s,
      description: content_for("meta[name='description']"),
      keywords: content_for("meta[name='keywords']"),
      news_keywords: content_for("meta[name='news_keywords']"),
      tag: content_for("meta[property='article:tag']"),
      copyright: content_for("meta[name='copyright']"),
      author: content_for("meta[name='author']")
    }
  end

  private

  def content_for(selector)
    page.search(selector).attr('content').to_s
  end

end
