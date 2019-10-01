# Sites scraper for your list - PRs are welcome!

List of supported site:

* ...


### How to contribute:

1. Write site parser at a service in services module, inside ItemParsers. For example: ItemParsers::ExampleCom
2. Update method `by_url` inside `ItemParsers::Detail` that support your parser
3. Test your result by url: `localhost:3000/parsers/details?url=YOUR_PARSED_PAGE_URL`
