require_relative '../../../sbmt_pact_helper'

require 'pact_broker/client'

describe PactBroker::Client::Versions, pact: true do

  pact_broker
  include_context "pact broker"
  include_context "pact broker - ffi overrides"

  let(:get_headers) { { "Accept" => "application/hal+json, application/json" } }
  let(:pact_broker_base_url) { "http://127.0.0.1:9999" }

  describe "retrieving the latest pacticipant version" do
    let(:latest_version_path) { "/HAL-REL-PLACEHOLDER-INDEX-PB-LATEST-VERSION-{pacticipant}" }
    let(:latest_version_url) { pact_broker_base_url + latest_version_path }

    let(:interaction) do
      new_interaction
        .given("the pb:latest-version relation exists in the index resource")
        .upon_receiving("a request for the index resource")
        .with_request(
            method: :get,
            path: '/',
            headers: get_headers).
          will_respond_with(
            status: 200,
            headers: pact_broker_response_headers,
            body: {
              _links: {
                :'pb:latest-version' => {
                  href: match_regex(/http:\/\/.*{pacticipant}\/latest-version/, latest_version_url)
                }
              }
            }
          )

      new_interaction
        .given("'Condor' exists in the pact-broker with the latest version 1.2.3")
        .upon_receiving("a request to retrieve the latest version of Condor")
        .with_request(
            method: :get,
            path: '/HAL-REL-PLACEHOLDER-INDEX-PB-LATEST-VERSION-Condor',
            headers: get_headers).
          will_respond_with(
            status: 200,
            headers: pact_broker_response_headers,
            body: {
              number: '1.2.3',
              _links: {
                self: {
                  href: match_regex(%r{http://.*}, 'http://localhost:9999/some-url')
                }
              }
            }
          )
    end

    it "returns the version hash" do
      interaction.execute do | mockserver |        
        version_hash = pact_broker_client.pacticipants.versions.latest(pacticipant: 'Condor')
        expect(version_hash[:number]).to eq '1.2.3'
        expect(version_hash[:_links][:self][:href]).to eq 'http://localhost:9999/some-url'
      end
    end
  end

  describe "retrieving the latest pacticipant version for a tag" do
    let(:latest_tagged_version_path) { "/HAL-REL-PLACEHOLDER-INDEX-PB-LATEST-TAGGED-VERSION-{pacticipant}-{tag}" }
    let(:latest_tagged_version_url) { pact_broker_base_url + latest_tagged_version_path }

    let(:interaction) do
      new_interaction
        .given("the pb:latest-tagged-version relation exists in the index resource")
        .upon_receiving("a request for the index resource")
        .with_request(
            method: :get,
            path: '/',
            headers: get_headers).
          will_respond_with(
            status: 200,
            headers: pact_broker_response_headers,
            body: {
              _links: {
                :'pb:latest-tagged-version' => {
                  href: match_regex(/http:\/\/.*{pacticipant}.*{tag}/, latest_tagged_version_url)
                }
              }
            }
          )

      new_interaction
        .given("'Condor' exists in the pact-broker with the latest tagged 'production' version 1.2.3")
        .upon_receiving("a request to retrieve the latest 'production' version of Condor")
        .with_request(
            method: :get,
            path: '/HAL-REL-PLACEHOLDER-INDEX-PB-LATEST-TAGGED-VERSION-Condor-production',
            headers: get_headers).
          will_respond_with(
            status: 200,
            headers: pact_broker_response_headers,
            body: {
              number: '1.2.3',
              _links: {
                self: {
                  href: match_regex( %r{http://.*}, 'http://localhost:9999/some-url')
                }
              }
            }
          )
    end

    it "returns the version hash" do
      interaction.execute do | mockserver |
        version_hash = pact_broker_client.pacticipants.versions.latest(pacticipant: 'Condor', tag: 'production')
        expect(version_hash[:number]).to eq '1.2.3'
        expect(version_hash[:_links][:self][:href]).to eq 'http://localhost:9999/some-url'
      end
    end
  end
end