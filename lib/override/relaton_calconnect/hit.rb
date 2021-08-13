module RelatonCalconnect
  class Hit < ::RelatonBib::Hit
    ENDPOINT = "https://raw.githubusercontent.com/relaton/relaton-data-calconnect/main/data/".freeze

    # Parse page.
    # @return [RelatonCalconnect::CcBliographicItem]
    def fetch
      @fetch ||= begin
        code, year = @hit[:ref].split ":"
        year ||= @hit[:year]
        code += ":#{year}" if year
        code.downcase!.gsub! %r{[/\s:]}, "_"
        resp = Faraday.get "#{ENDPOINT}#{code}.xml"
        XMLParser.from_xml resp.body if resp.status == 200
      end
    end
  end
end
