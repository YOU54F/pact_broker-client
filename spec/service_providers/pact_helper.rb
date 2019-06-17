require 'spec_helper'
require 'pact/consumer/rspec'


Pact.configure do | config |
  config.logger.level = Logger::DEBUG
  config.doc_generator = :markdown
end

Pact.service_consumer 'Pact Broker Client' do

  has_pact_with "Pact Broker" do
    mock_service :pact_broker do
      port 1234
      pact_specification_version "2.0"
    end
  end

end

module PactBrokerPactHelperMethods

  def placeholder_path(relation, params = [])
    path = "/HAL-REL-PLACEHOLDER-#{relation.gsub(':', '-').upcase}"
    if params.any?
      joined_params = params.collect{ |param| "{#{param}}"}.join("-")
      path = "#{path}-#{joined_params}"
    end

    path
  end

  def placeholder_url(relation, params = [])
    "#{pact_broker.mock_service_base_url}#{placeholder_path(relation, params)}"
  end

  def placeholder_url_term(relation, params = [])
    regexp = "http:\/\/.*"
    if params.any?
      joined_params_for_regexp = params.collect{ |param| "{#{param}}"}.join(".*")
      regexp = "#{regexp}#{joined_params_for_regexp}"
    end

    Pact.term(placeholder_url(relation, params), /#{regexp}/)
  end

  def default_get_headers
    { 'Accept' => 'application/hal+json' }
  end

  def default_post_headers
    { 'Accept' => 'application/hal+json', 'Content-Type' => 'application/json' }
  end

  def mock_pact_broker_index(context)
    pact_broker
      .upon_receiving("a request for the index resource")
      .with(
          method: :get,
          path: '/',
          headers: context.get_request_headers).
        will_respond_with(
          status: 200,
          headers: context.pact_broker_response_headers,
          body: {
            _links: {
              :'pb:webhooks' => {
                href: placeholder_url_term('pb:webhooks')
              }
            }
          }
        )
  end
end
