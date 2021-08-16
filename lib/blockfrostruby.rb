# frozen_string_literal: true

# gem build blockfrostruby
# gem install ./blockfrostruby-0.1.0.gem
# require 'blockfrostruby'
# Blockfrostruby::CardanoMainNet

require_relative 'blockfrostruby/version'

module Request
  require 'net/http'
  require 'json'

  def self.get_response(url, project_id, _params = {}, _headers = nil)
    # params = { :limit => 10, :page => 3, :order => 'desc' }
    # response = Net::HTTP.get_response(URI(url))
    uri = URI(url)
    req = Net::HTTP::Get.new(uri)
    req['project_id'] = project_id
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') { |http| http.request(req) }
    format_response(response)
  end

  def self.get_all_pages(url)
    # https://docs.ruby-lang.org/en/2.0.0/Net/HTTP.html
    # uri = URI('http://example.com/some_path?query=string')
    # Net::HTTP.start(uri.host, uri.port) do |http|
    #   request = Net::HTTP::Get.new uri
    #   response = http.request request # Net::HTTPResponse object
    # end
  end

  private

  def self.format_response(response)
    # resque from uncoded:
    # Net::HTTP.get(uri).encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
    body = response.header.content_type == 'application/json' ? JSON.parse(response.body) : response.body
    { status: response.code, body: body } # In config return whole object, default this one
    # Look in the JS implementation
  end
end


module HealthEndpoints
  extend Request

  @@url = ""
  @@project_id = ""

  def self.set_url(value)
    @@url = value
  end

  def self.set_project_id(value)
    @@project_id = value
  end

  def self.get_root
    Request.get_response("#{self.url}/", @@project_id )
  end

  def get_health
    Request.get_response("#{@@url}/health", @@project_id )
  end

  def self.get_health_clock
    Request.get_response("#{self.url}/health/clock", @@project_id )
  end
end


module Blockfrostruby

  class Error < StandardError; end
  # raise error if body status error

  class CardanoMainNet
    CARDANO_MAINNET_URL = "https://cardano-mainnet.blockfrost.io/api/v0" #To config
    include HealthEndpoints # Array

    def initialize(project_id)
      @project_id = project_id # Can be removed
      HealthEndpoints.set_url(CARDANO_MAINNET_URL)
      HealthEndpoints.set_project_id(@project_id)
    end

    def self.get_custom_url
      # used when user wants to add something in the url manually
      # extend Request
    end

    private

    def self.set_vars_for_endpoints_modules(modules)
      # TODO: refactor and implement setter for all endpoints modules
      # Maybe enpoints modules can be grouped in array
    end
  end

  class CardanoTestNet < CardanoMainNet
    CARDANO_TESTNET_URL = "another_url" #To config

    def initialize(project_id)
      super
      HealthEndpoints.set_url(CARDANO_TESTNET_URL)
    end
  end
end
