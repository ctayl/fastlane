require_relative '../model'
require_relative './bundle_id_capability'
require_relative '../../portal/portal_client'

module Spaceship
  class ConnectAPI
    class BundleId
      include Spaceship::ConnectAPI::Model

      attr_accessor :identifier
      attr_accessor :name
      attr_accessor :seed_id
      attr_accessor :platform

      attr_accessor :bundle_id_capabilities

      attr_mapping({
        "identifier" => "identifier",
        "name" => "name",
        "seedId" => "seed_id",
        "platform" => "platform",

        "bundleIdCapabilities" => 'bundle_id_capabilities'
      })

      def self.type
        return "bundleIds"
      end

      #
      # Helpers
      #

      def supports_catalyst?
        return bundle_id_capabilities.any? do |capability|
          capability.is_type?(Spaceship::ConnectAPI::BundleIdCapability::Type::MARZIPAN)
        end
      end

      #
      # API
      #

      def self.all(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_bundle_ids(filter: filter, includes: includes).all_pages
        return resps.flat_map(&:to_models)
      end

      def self.find(identifier, includes: nil, client: nil)
        client ||= Spaceship::ConnectAPI
        return all(client: client, filter: { identifier: identifier }, includes: includes).find do |app|
          app.identifier == identifier
        end
      end

      def self.get(client: nil, bundle_id_id: nil, includes: nil)
        client ||= Spaceship::ConnectAPI
        return client.get_bundle_id(bundle_id_id: bundle_id_id, includes: includes).first
      end

      def self.create(client: nil, name: nil, platform: nil, identifier: nil, seed_id: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.post_bundle_id(name: name, platform: platform, identifier: identifier, seed_id: seed_id)
        return resp.to_models.first
      end

      #
      # BundleIdsCapabilities
      #

      def get_capabilities(client: nil, includes: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.get_bundle_id_capabilities(bundle_id_id: id, includes: includes)
        return resp.to_models
      end

      def create_capability(capability_type, settings: [], client: nil)
        raise "capability_type is required " if capability_type.nil?

        client ||= Spaceship::ConnectAPI
        resp = client.post_bundle_id_capability(bundle_id_id: id, capability_type: capability_type, settings: settings)
        return resp.to_models.first
      end

      def update_capability(capability_type, enabled: false, settings: [], client: nil)
        raise "capability_type is required " if capability_type.nil?

        client ||= Spaceship::ConnectAPI
        resp = client.patch_bundle_id_capability(bundle_id_id: id, team_id: Spaceship::Portal.client.team_id, enabled: enabled, capability_type: capability_type, settings: settings)
        return resp.to_models.first
      end
    end
  end
end
