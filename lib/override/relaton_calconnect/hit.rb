module RelatonCalconnect
  class Hit
    ENDPOINT = "https://raw.githubusercontent.com/relaton/relaton-data-calconnect/main/data/".freeze

    # Parse page.
    # @return [RelatonCalconnect::CcBliographicItem, nil]
    def fetch # rubocop:disable Metrics/MethodLength
      @fetch ||= begin
        code, year = @hit[:ref].split ":"
        year ||= @hit[:year]
        code += ":#{year}" if year
        ref = code.upcase.gsub %r{[/\s:]}, "_"
        resp = Faraday.get "#{ENDPOINT}#{ref}.yaml"
        if resp.status == 200
          hash = YAML.safe_load resp.body
          CcBibliographicItem.from_hash hash
        end
      end
    end
  end
end
