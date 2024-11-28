require 'spec_helper'
require 'pact_broker/client'
require_relative '../../../sbmt_pact_helper'


describe PactBroker::Client::Versions, pact: true do

  pact_broker
  include_context "pact broker"
  include_context "pact broker - ffi overrides"

  describe "tagging a version with prod details" do
    let(:repository_ref) { "packages/condor-#{version}" }

    let(:tag_options) { {pacticipant: 'Condor', version: version, repository_ref: repository_ref, :tag => 'prod'} }
    context "when the component exists" do
      let(:interaction) do
        new_interaction.
        given("'Condor' exists in the pact-broker").
        upon_receiving("a request to tag the production version of Condor").
        with_request(
            method: :put,
            path: '/pacticipants/Condor/versions/1.3.0/tags/prod',
            headers: default_request_headers).
          will_respond_with(
            status: 201,
            headers: pact_broker_response_headers,
            body: {
              _links: {
                self: {
                  href:
                  Pact::Term.new(
                    generate: 'http://localhost:9999/pacticipants/Condor/versions/1.3.0/tags/prod',
                    matcher: %r{http://.*/pacticipants/Condor/versions/1.3.0/tags/prod})
                }
              }
            }
          )
      end
      it "returns true" do
        interaction.execute do | mockserver |
          expect(pact_broker_client.pacticipants.versions.tag tag_options).to be true
        end
      end
    end
    context "when the component does not exist" do
      let(:interaction) do
        new_interaction.
        given("'Condor' does not exist in the pact-broker").
        upon_receiving("a request to tag the production version of Condor").
        with_request(
          method: :put,
          path: '/pacticipants/Condor/versions/1.3.0/tags/prod',
          headers: default_request_headers).
          will_respond_with(
            status: 201,
            headers: pact_broker_response_headers,
            body: {
              _links: {
                self: {
                  href:
                  Pact::Term.new(
                    generate: 'http://localhost:9999/pacticipants/Condor/versions/1.3.0/tags/prod',
                    matcher: %r{http://.*/pacticipants/Condor/versions/1.3.0/tags/prod})
                }
              }
            }
          )
      end
      it "returns true" do
        interaction.execute do | mockserver |
          expect(pact_broker_client.pacticipants.versions.tag tag_options).to be true
        end
      end
    end

    context "when the tag already exists" do
      let(:interaction) do
        new_interaction.
        given("'Condor' exists in the pact-broker with version 1.3.0, tagged with 'prod'").
        upon_receiving("a request to tag the production version of Condor").
        with_request(
            method: :put,
            path: '/pacticipants/Condor/versions/1.3.0/tags/prod',
            headers: default_request_headers).
          will_respond_with(
            status: 200,
            headers: pact_broker_response_headers,
            body: {
              _links: {
                self: {
                  href:
                  Pact::Term.new(
                    generate: 'http://localhost:9999/pacticipants/Condor/versions/1.3.0/tags/prod',
                    matcher: %r{http://.*/pacticipants/Condor/versions/1.3.0/tags/prod})
                }
              }
            }
          )
        end

        it "returns true" do
          interaction.execute do | mockserver |
            expect(pact_broker_client.pacticipants.versions.tag tag_options).to be true
          end
        end
    end
  end

end