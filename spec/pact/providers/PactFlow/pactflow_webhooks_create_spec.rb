require_relative '../../../sbmt_pact_helper'
require 'pact_broker/client/webhooks/create'

RSpec.describe "creating a webhook in PactFlow", pact: true do

  pactflow
  include_context "pact broker"
  include_context "pact broker - ffi overrides"
  include PactBrokerPactHelperMethods

  let(:params) do
    {
      description: "a webhook",
      events: %w{contract_content_changed},
      http_method: "POST",
      url: "https://webhook",
      headers: { "Foo" => "bar", "Bar" => "foo"},
      body: body,
      team_uuid: "2abbc12a-427d-432a-a521-c870af1739d9"
    }
  end

  let(:body) { { some: "body" }.to_json }

  let(:request_body) do
    {
      "description" => "a webhook",
      "events" => [
        "name" => "contract_content_changed"
      ],
      "request" => {
        "url" => "https://webhook",
        "method" => "POST",
        "headers" => {
          "Foo" => "bar",
          "Bar" => "foo"
        },
        "body" => {
          "some" => "body"
        },
      },
      "teamUuid" => "2abbc12a-427d-432a-a521-c870af1739d9"
    }
  end

  let(:response_status) { 201 }
  let(:success_response) do
    {
      status: response_status,
      headers: pact_broker_response_headers,
      body: {
        description: match_type_of("a webhook"),
        teamUuid: "2abbc12a-427d-432a-a521-c870af1739d9",
        _links: {
          self: {
            href: match_regex(%r{http://.*},'http://localhost:1234/some-url'),
            title: match_type_of("A title")
          }
        }
      }
    }
  end

  let(:pactflow_mock_service_base_url) { "http://127.0.0.1:9998" }
  let(:pact_broker_client_options) { {} }

  subject { PactBroker::Client::Webhooks::Create.call(params, pactflow_mock_service_base_url, pact_broker_client_options) }

  context "when a valid webhook with a team specified is submitted" do
    before do
      mock_pact_broker_index(self, pactflow_mock_service_base_url)
      new_interaction
        .given("a team with UUID 2abbc12a-427d-432a-a521-c870af1739d9 exists")
        .upon_receiving("a request to create a webhook for a team")
        .with_request(
            method: :post,
            path: '/HAL-REL-PLACEHOLDER-PB-WEBHOOKS',
            headers: post_request_headers,
            body: request_body)
        .will_respond_with(**success_response)
    end

    it "returns a CommandResult with success = true" do
      execute_http_pact do |mock_server|
        expect(subject).to be_a PactBroker::Client::CommandResult
        expect(subject.success).to be true
        expect(subject.message).to eq "Webhook \"a webhook\" created"
      end
    end
  end
end