require_relative '../../../sbmt_pact_helper'

require 'pact_broker/client/pacticipants/create'

RSpec.describe "creating or updating a pacticipant", pact: true do
  pact_broker
  include_context "pact broker"
  include_context "pact broker - ffi overrides"
  include PactBrokerPactHelperMethods

  let(:pact_broker_base_url) { "http://127.0.0.1:9999" }

  before do
    index_links = {
      'pb:pacticipants' => match_regex(%r{http://.*}, 'http://localhost:9999/pacticipants'),
      'pb:pacticipant' => match_regex(%r{http://.*\{pacticipant\}}, 'http://localhost:9999/pacticipants/{pacticipant}'),
    }
    mock_pact_broker_index_with_relations(self, index_links, "the pacticipant relations are present")
  end

  let(:params) do
    {
      name: "Foo",
      repository_url: "http://foo"
    }
  end

  let(:request_body) { { name: "Foo", repositoryUrl: "http://foo" } }


  let(:response_status) { 201 }
  let(:create_success_response) do
    {
      status: response_status,
      headers: pact_broker_response_headers,
      body: {
        name: "Foo",
        repositoryUrl: "http://foo",
        _links: {
          self: {
            href: match_regex(%r{http://.*}, 'http://localhost:9999/pacticipants/Foo'),
          }
        }
      }
    }
  end

  let(:get_success_response) do
    {
      status: 200,
      headers: pact_broker_response_headers,
      body: {
        _links: {
          self: {
            href: match_regex(%r{http://.*}, 'http://localhost:9999/pacticipants/Foo'),
          }
        }
      }
    }
  end

  let(:pact_broker_client_options) { { pact_broker_base_url: pact_broker_base_url} }
  let(:options) { {} }

  subject { PactBroker::Client::Pacticipants2::Create.call(params, options, pact_broker_client_options) }

  context "when the pacticipant does not already exist" do
    let(:interaction) do
      new_interaction
        .upon_receiving("a request to retrieve a pacticipant")
        .with_request(
            method: :get,
            path: '/pacticipants/Foo',
            headers: get_request_headers)
        .will_respond_with(status: 404)

      new_interaction
        .upon_receiving("a request to create a pacticipant")
        .with_request(
            method: :post,
            path: '/pacticipants',
            headers: post_request_headers,
            body: request_body)
        .will_respond_with(**create_success_response)
    end

    it "returns a CommandResult with success = true" do
      interaction.execute do | mockserver |        
        expect(subject).to be_a PactBroker::Client::CommandResult
        expect(subject.success).to be true
        expect(subject.message).to include "Pacticipant \"Foo\" created"
      end
    end
  end

  context "when the pacticipant does already exist" do
    let(:interaction) do
      new_interaction
        .given("a pacticipant with name Foo exists")
        .upon_receiving("a request to retrieve a pacticipant")
        .with_request(
          method: :get,
          path: '/pacticipants/Foo',
          headers: get_request_headers)
        .will_respond_with(**get_success_response)

      new_interaction
        .given("a pacticipant with name Foo exists")
        .upon_receiving("a request to update a pacticipant")
        .with_request(
          method: :patch,
          path: '/pacticipants/Foo',
          headers: post_request_headers,
          body: request_body)
        .will_respond_with(**create_success_response)
    end

    let(:response_status) { 200 }

    it "returns a CommandResult with success = true" do
      interaction.execute do | mockserver |        
        expect(subject).to be_a PactBroker::Client::CommandResult
        expect(subject.success).to be true
        expect(subject.message).to include "Pacticipant \"Foo\" updated"
      end
    end
  end
end
