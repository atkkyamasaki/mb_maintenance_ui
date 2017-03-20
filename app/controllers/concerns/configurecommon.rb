module Configurecommon
    extend ActiveSupport::Concern

    included do
      # ここにcallback等
    end

    private

    def _defaultConfWrite(valArray, key, value)
        return valArray[key] = value unless valArray.has_key?(key)
    end

    def _confChangeCmd(filePath, key, value)
        if %x(cat #{filePath} | grep -E ^#{key}).empty? 
            %x(sed -i -e '/^#.#{key}=/a\\#{key}=#{value}' #{filePath})
        elsif 
            %x(sed -i -e 's/^#{key}.*$/#{key}=#{value}/g' #{filePath})
        end
    end
end
