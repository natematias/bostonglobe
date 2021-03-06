require 'uuid'

module Parsers
  class Default

    def initialize(job, config, store)
      @job = job
      @config = config
      @store = store
    end

    # return the id of your document or a new id.
    # overwrite if you want to use an attribute from your source
    def generate_id(article)
      (UUID.new).generate
    end

    def fetch
      # fetch the data from wherever it is.
      # fetch can get the single item or many
    end

    def parse
      # modify your document into an article form.
      # parse should be called PER ITEM.
    end

    def process
      self.fetch
    end

  end
end