module ActiveRecord
  def Base.serialize_json(attr, args = {})
    args[:symbolize] = true unless args.include? :symbolize

    self.send(:define_method, attr) do
      begin
        data = ActiveSupport::JSON.decode(read_attribute(attr))
        args[:symbolize] ? data.symbolize_keys : data
      rescue
        nil
      end
    end

    self.send(:define_method, "#{attr}=") do |data|
      write_attribute attr, data.to_json
    end
  end
end
