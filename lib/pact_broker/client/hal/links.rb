require 'uri'
require 'delegate'

module PactBroker
  module Client
    module Hal
      class Links
        def initialize(href, key, links)
          @href = href
          @key = key
          @links = links
        end

        def names
          @names ||= links.collect(&:name).compact.uniq
        end

        def find!(name, not_found_message = nil)
          link = find(name)
          if link
            link
          else
            message = not_found_message || "Could not find relation '#{key}' with name '#{name}' in resource at #{href}."
            available_options = names.any? ? names.join(", ") : "<none found>"
            raise RelationNotFoundError.new(message.chomp(".") + ". Available options: #{available_options}")
          end
        end

        def find(name)
          links.find{ | link | link.name == name }
        end

        private

        attr_reader :links, :key, :href
      end
    end
  end
end
