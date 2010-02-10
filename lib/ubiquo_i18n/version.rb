module UbiquoI18n
  def self.version
    VERSION::STRING
  end
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 7
    TINY  = 0

    STRING = [MAJOR, MINOR, TINY].join('.')
  end
end
