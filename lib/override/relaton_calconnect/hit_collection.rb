require_relative "hit"

module RelatonCalconnect
  class HitCollection < RelatonBib::HitCollection
    # @param ref [Strig]
    # @param year [String]
    def initialize(ref, year = nil)
      super
      @array = []
      hit = Hit.new({ ref: ref, year: year }, self)
      @array << hit if hit.fetch
    end
  end
end
