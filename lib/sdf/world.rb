module SDF
    class World < Element
        # Return an empty world
        def self.empty(name: "world", version: nil)
            if version && !version.respond_to?(:to_str)
                version = SDF.numeric_version_to_string(version)
            end

            xml = REXML::Document.new
            root = xml.add_element "sdf"
            root.attributes["version"] = version if version
            world = root.add_element "world"
            world.attributes["name"] = name
            Root.new(xml.root).each_world.first
        end

        xml_tag_name "world"

        # Enumerates the models from this world
        #
        # @yieldparam [Model] model
        def each_model
            return enum_for(__method__) unless block_given?

            xml.elements.each do |element|
                yield(Model.new(element, self)) if element.name == "model"
            end
        end

        # Give access to the information in the world's spherical_coordinates
        # element
        #
        # @return [SphericalCoordinates]
        # @raise Invalid if there is no such element in the SDF
        def spherical_coordinates
            @spherical_coordinates ||= child_by_name(
                "spherical_coordinates", SphericalCoordinates
            )
        end

        # Enumerate the world-level plugins
        def each_plugin
            return enum_for(__method__) unless block_given?

            xml.elements.each do |element|
                yield(Plugin.new(element, self)) if element.name == "plugin"
            end
        end
    end
end
