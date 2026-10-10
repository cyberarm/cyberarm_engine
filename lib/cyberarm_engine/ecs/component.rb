module CyberarmEngine
  module ECS
    # Components MUST not have "logic," only data.
    class Component
      InternalEncoder = Data.define(:pack, :min, :max, :encoder, :decoder)

      # Note: all encoders use big endian
      INTERNAL_ENCODING_DATA = {
        float: InternalEncoder.new("g", -Float::INFINITY, Float::INFINITY, nil, nil),
        double: InternalEncoder.new("G", -Float::INFINITY, Float::INFINITY, nil, nil),
        int8: InternalEncoder.new("c", -128, 127, nil, nil),
        uint8: InternalEncoder.new("C", 0, 255, nil, nil),
        int16: InternalEncoder.new("s>", -32_768, 32_767, nil, nil),
        uint16: InternalEncoder.new("n", 0, 65_535, nil, nil),
        int32: InternalEncoder.new("l>", -2_147_483_648, 2_147_483_647, nil, nil),
        uint32: InternalEncoder.new("N", 0, 4_294_967_295, nil, nil),
        int64: InternalEncoder.new("q>", -9_223_372_036_854_775_808, 9_223_372_036_854_775_807, nil, nil),
        uint64: InternalEncoder.new("Q>", 0, 18_446_744_073_709_551_615, nil, nil),
        string: InternalEncoder.new("Z", nil, nil, nil, nil),
        vector_float: InternalEncoder.new("g4", nil, nil, ->(v) { [v.x, v.y, v.z, v.w] }, ->(v, a) { v.x = a[0]; v.y = a[1]; v.z = a[2]; v.w = a[4] }),
        vector_double: InternalEncoder.new("G4", nil, nil, ->(v) { [v.x, v.y, v.z, v.w] }, ->(v, a) { v.x = a[0]; v.y = a[1]; v.z = a[2]; v.w = a[4] }),
        vector_int8: InternalEncoder.new("c4", nil, nil, ->(v) { [v.x, v.y, v.z, v.w] }, ->(v, a) { v.x = a[0]; v.y = a[1]; v.z = a[2]; v.w = a[4] }),
        vector_int16: InternalEncoder.new("s>4", nil, nil, ->(v) { [v.x, v.y, v.z, v.w] }, ->(v, a) { v.x = a[0]; v.y = a[1]; v.z = a[2]; v.w = a[4] }),
        vector_int32: InternalEncoder.new("l>4", nil, nil, ->(v) { [v.x, v.y, v.z, v.w] }, ->(v, a) { v.x = a[0]; v.y = a[1]; v.z = a[2]; v.w = a[4] }),
      }.freeze

      @identifier = nil
      @values = []

      def self.register_value(type, name, value, encoder = INTERNAL_ENCODING_DATA[type])
        pp [type, name, value, encoder]
      end

      def self.register_custom_value(type, name, value, packed, encoder, decoder)
        pp [type, name, value, packed, encoder, decoder]
      end

      def self.identifier(value = nil)
        unless value
          value = [File.basename(__FILE__).bytes.each_slice(4).map(&:sum).sum^0xffffffff].pack("N").unpack1("N")
        end

        @identifier = value
      end

      def self.float(name, value = 0.0)
        register_value(:float, name, value)
      end

      def self.double(name, value = 0.0)
        register_value(:double, name, value)
      end

      def self.int8(name, value = 0)
        register_value(:int8, name, value)
      end

      def self.uint8(name, value = 0)
        register_value(:uint8, name, value)
      end

      def self.int16(name, value = 0)
        register_value(:int16, name, value)
      end

      def self.uint16(name, value = 0)
        register_value(:uint16, name, value)
      end

      def self.int32(name, value = 0)
        register_value(:int32, name, value)
      end

      def self.uint32(name, value = 0)
        register_value(:uint32, name, value)
      end

      def self.int64(name, value = 0)
        register_value(:int64, name, value)
      end

      def self.uint64(name, value = 0)
        register_value(:uint64, name, value)
      end

      def self.string(name, value = "")
        register_value(:string, name, value)
      end

      def self.vector_float(name, value = CyberarmEngine.new(0.0, 0.0, 0.0, 0.0))
        register_value(:vector_float, name, value)
      end

      def self.vector_double(name, value = CyberarmEngine.new(0.0, 0.0, 0.0, 0.0))
        register_value(:vector_double, name, value)
      end

      def self.vector_int8(name, value = CyberarmEngine.new(0, 0, 0, 0))
        register_value(:vector_int8, name, value)
      end

      def self.vector_int16(name, value = CyberarmEngine.new(0, 0, 0, 0))
        register_value(:vector_int16, name, value)
      end

      def self.vector_int32(name, value = CyberarmEngine.new(0, 0, 0, 0))
        register_value(:vector_int32, name, value)
      end

      def self.custom(name, value, pack, encoder, decoder)
        register_value(:custom, name, value, pack, encoder, decoder)
      end

      def self.custom_unserializable(name, value)
        register_value(:custom, name, value)
      end
    end
  end
end
