module Finders
  class KlassFinder
    def initialize(code)
      @code = code
    end

    def find
      unless standard_key.empty?
        finder_klasses[standard_key.to_sym]
      end
    end

    def self.find(code)
      new(code).find
    end

    private

    def finder_klasses
      @finder_klasses ||= {
        iso: Finders::IsoStandard,
      }
    end

    def processor_patterns
      @processor_patterns ||= {
        iso: { prefix: /ISO/, default: %r{^(ISO)[ /]} },
      }
    end

    def standard_key
      code = @code.upcase

      processor_patterns.select do |name, regex|
        if regex[:prefix].match(code) || regex[:default].match(code)
          return name
        end
      end
    end
  end
end
