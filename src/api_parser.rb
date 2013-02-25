require 'lib/parser'
require 'open-uri'
require 'cgi'

module Parsers
  class APIParser < Parsers::Default

    def initialize(job, config, store)

      super(job, config, store)

      # fix url
      @job[:url] = check_url(@job[:url])

      # store the job to start. we will save it
      # again when we are done adding items to it.
      @job[:status] = 'getting articles'
      @store.save_job(@job)
    end

    # we have:
    # @job with a job_id and url
    def fetch

      fetch_all_articles(@job[:url])

      # when done fetching save the job
      @store.update_job(@job)

    end

    def generate_id(entry)
      
      # determine article id somehow here.
      entry["id"]

    end

    def parse(entry)
      
      article = {}

      article["id"] = self.generate_id(entry)

      # only save articles that don't already exist.
      if (!@store.has_article?(article))
        article["url"] = entry["data"]["canonicalurl"][0]
        article["title"] = entry["data"]["headline"][0]
        article["body"] = entry["data"]["summary"][0]
        article["original_body"] = entry["data"]["summary"][0]
        article["pub_date"] = entry["data"]["printpublicationdate"][0]
        article["byline"] = entry["data"]["byname"][0]

        # save the article with whatever store we're using.
        @store.save_article(article)
      end

      # save this article as being a part of the job.
      @job[:article_ids] << article["id"]

      article
    end

    private

    def fetch_all_articles(url)

      puts "fetching #{url}"
      data = open(url).read
      
      parsed_data = JSON.parse(data)

      # how many?
      start_index = get_start(url)
      total = parsed_data["hits"]["found"]
      on_current_page = parsed_data["hits"]["hit"].length

      articles = parsed_data["hits"]["hit"]

      articles.each do |article|
        self.parse(article)
      end

      if (start_index + on_current_page + 1 < total)
        new_url = set_start(url, start_index + on_current_page)
        fetch_all_articles(new_url)
      end


    end 

    def get_start(url)
      /start=([0-9]+)/.match(url)[1].to_i rescue 0
    end

    def set_start(url, new_start)
      url.gsub(/start=[0-9]+/, "start=#{new_start}")
    end

    # overwrite the return fields to just be what we need.
    def check_url(url)
      return url.gsub(/return-fields=[[a-z_\-0-9]+,?]+/m, "return-fields=canonicalurl,headline,summary,printpublicationdate,byname")
    end

  end
end