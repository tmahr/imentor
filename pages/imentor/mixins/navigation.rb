module IMentorPage

  module Navigation

    def locator(key, *options)
      hash = {
        "" => [],
      }
      hash.has_key?(key) ? hash[key] : defined?(super) ? super : raise("Locator [#{key}] does not exist in #{self.class.to_s}")
    end

  end

end