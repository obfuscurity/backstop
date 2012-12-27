module Backstop
  module Config
    def self.env!(key)
      ENV[key] || raise("missing #{key}")
    end

    def self.deploy; env!('DEPLOY'); end
    def self.port; env!('PORT').to_i; end
    def self.carbon_urls; env!('CARBON_URLS').split(','); end
    def self.prefixes; env!('PREFIXES').split(','); end
    def self.api_key; ENV['API_KEY']; end
  end
end
