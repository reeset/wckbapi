require 'uri'
require 'net/http'
require 'cgi'

module WCKBAPI 

  # The WCKBAPI::Client object provides a public facing interface to interacting
  # with the WorldCat Knowledgebank API
  #
  #   client = WCKBAPI::Client.new :wskey => [your world cat key], :debug => true|false, :institution_id => [your institution id]
  # options:
  #    wskey
  #
  #
  # More information can be found at:
  #   http://worldcat.org/devnet/wiki/SearchAPIDetails  
  
  class Client

    # The constructor which must be passed a valid base url for an oai 
    # service:
    #
    # If you want to see debugging messages on STDERR use:
    # :debug => true
    
    def initialize(options={})
      @debug = options[:debug]
      @wskey = options[:wskey]
      @institution_id = options[:institution_id]
    end

    # Equivalent to a Identify request. You'll get back a OAI::IdentifyResponse
    # object which is essentially just a wrapper around a REXML::Document 
    # for the response.
    
    #def OpenSearch(opts={}) 
    #  @base = URI.parse WORLDCAT_OPENSEARCH
    #  opts["wskey"] = @wskey
    #  xml = do_request(opts)
    #  return OpenSearchResponse.new(xml)
    #end

    def GetCollectionInfo(opts={})
       opts[:wskey] = @wskey 
       opts[:alt] = 'json'
       if opts[:type] == nil
          if opts[:institution_id] != nil
             @base = URI.parse WORLDCAT_KB_URL + "collections/" + opts[:collection_uid] + "," + opts[:institution_id]
          else
	     @base = URI.parse WORLDCAT_KB_URL + "collections/" + opts[:collection_uid]
          end
          opts.delete(:institution_id)
          opts.delete(:collection_uid)
          data = do_request(opts)
          json = JSON.parse(data) 
	  objC = Collection.new()
          objC.load(json)
          return Array(objC) 
       else
	  opts.delete(:type)
	  @base = URI.parse WORLDCAT_KB_URL + "collections/search"
          data = do_request(opts)
          json = JSON.parse(data)
          objArray = Array.new()
          json['entries'].each {|item|
	    objC = Collection.new()
            objC.load(item)
	    objArray.push(objC)     
          }
	  return objArray
       end
    end

    #def GetRecord(opts={})
    #  if opts[:type] == 'oclc'
    #     @base = URI.parse "http://www.worldcat.org/webservices/catalog/content/" + opts[:id]
    #  else
    #	 @base = URI.parse 'http://www.worldcat.org/webservices/catalog/content/isbn/' + opts[:id]
    #  end
    #  opts.delete("type")
    #  opts["wskey"] = @wskey
    #  xml = do_request(opts)
    #  return GetRecordResponse.new(xml)
    #end


    private 

    def do_request(hash)
      uri = @base.clone

      # build up the query string
      parts = hash.entries.map do |entry|
        #key = studly(entry[0].to_s)
        key = entry[0].to_s
        value = entry[1]
        value = CGI.escape(entry[1].to_s)
        "#{key}=#{value}"
      end
      uri.query = parts.join('&')
      debug("doing request: #{uri.to_s}")
      begin
        data = Net::HTTP.get(uri)
        debug("got response: #{data}")
	return data 
      rescue SystemCallError=> e
        #raise WCKBAPI::Exception, 'HTTP level error during WCKBAPI  request: '+e, caller
      end
    end

    # convert foo_bar to fooBar thus allowing our ruby code to use
    # the typical underscore idiom
    def studly(s)
      s.gsub(/_(\w)/) do |match|
        match.sub! '_', ''
        match.upcase
      end
    end

    def debug(msg)
      $stderr.print("#{msg}\n") if @debug
    end

     def to_h(default=nil)
        Hash[ *inject([]) { |a, value| a.push value, default || yield(value) } ]
     end

  end
end
