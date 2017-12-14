module EmailFootprint
  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap { |log| log.progname = name }
    end
  end
end
