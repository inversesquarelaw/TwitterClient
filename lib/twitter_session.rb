require 'json'
require 'launchy'
require 'oauth'
require 'yaml'

class TwitterSession
  CONSUMER_KEY = "IX88tSFi2sW8XFNT04f1eQ"
  CONSUMER_SECRET = "6GYfnUaDGanrabJL4kcM1Z9nBGTtQFYfXYNny110q0"

  CONSUMER = OAuth::Consumer.new(
    CONSUMER_KEY, CONSUMER_SECRET, :site => "https://twitter.com"
  )

  TOKEN_FILE_NAME = "twitter_token_file"

  def self.get(path, query_values = nil)
    url = path_to_url(path, query_values)
    JSON.parse(self.access_token.get(url).body)
  end

  def self.post(path, payload = nil)
    url = path_to_url(path)
    JSON.parse(self.access_token.post(url, payload).body)
  end

  # Helper so I don't need to repeat `"https://api.twitter.com/"`
  # everywhere.
  def self.path_to_url(path, query_values = nil)
    Addressable::URI.new(
      :scheme => "https",
      :host => "api.twitter.com",
      :path => "/1.1/#{path}.json",
      :query_values => query_values
    ).to_s
  end

  def self.access_token
    return @access_token unless @access_token.nil?

    if File.exist?(TOKEN_FILE_NAME)
      @access_token = File.open(TOKEN_FILE_NAME) { |f| YAML.load(f) }
    else
      @access_token = request_access_token
      File.open(TOKEN_FILE_NAME, "w") do |f|
        YAML.dump(@access_token, f)
      end

      @access_token
    end
  end

  def self.request_access_token
    # This is the bit that makes the user actually go through the
    # auth flow.

    request_token = CONSUMER.get_request_token

    authorize_url = request_token.authorize_url
    puts "Go to this URL: #{authorize_url}"
    Launchy.open(authorize_url)

    puts "Login, and type your verification code in"
    oauth_verifier = gets.chomp

    request_token.get_access_token(:oauth_verifier => oauth_verifier)
  end
end
