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

    def GetEntry(opts = {})
       opts[:wskey] = @wskey
       opts[:alt] = 'json'
       if opts[:id] == nil
          @base = URI.parse WORLDCAT_KB_URL + "entries/" + opts[:collection_uid] + "," + opts[:entry_uid]
          opts.delete(:collection_uid)
          opts.delete(:entry_uid)
       else
	  @base = URI.parse opts[:id]
	  opts.delete(:id)
       end

       data = do_request(opts)
       json = JSON.parse(data)
       objResult = Result.new()
       objResult.query = ""
       objResult.startIndex = 1
       objResult.totalResults = 1
       objResult.itemsPerPage = 1
       objE = Entry.new()
       objE.load(json)
       return objResult, Array(objE)
    end

    def SearchEntries(opts={})
       opts[:wskey] = @wskey
       opts[:alt] = 'json'
       @base = URI.parse WORLDCAT_KB_URL + "entries/search"
       data = do_request(opts)
       json = JSON.parse(data)
       objArray = Array.new()
       objResult = Result.new()
       objResult.query = json['os:Query'] 
       objResult.startIndex = json['os:startIndex'] 
       objResult.totalResults = json['os:totalResults']
       objResult.itemsPerPage = json['os:itemsPerPage']
       json['entries'].each {|item|
	   objE = Entry.new()
           objE.load(item)
	   objArray.push(objE)
	}
	return objResult, objArray
     end

    def SearchProviders(opts={})
       opts[:type] = 'search'
       return GetProviderInfo(opts)
    end

    def GetProviderInfo(opts={})
       if opts == nil
         opts = Hash.new()
       end 

       opts[:wskey] = @wskey
       opts[:alt] = 'json'
       if opts[:type] == nil
          if opts[:collection_uid] == nil
     	     @base = URI.parse WORLDCAT_KB_URL + "providers"
          else
	     @base = URI.parse WORLDCAT_KB_URL + "providers/" + opts[:title]
	  end
	  opts.delete(:collection_uid)
          data = do_request(opts)
          json = JSON.parse(data)
          objResult = Result.new()
	  if json['entries'] != nil
             objResult.query =json['os:Query'] 
	     objResult.startIndex =json['os:startIndex'] 
	     objResult.totalResults = json['os:totalResults'] 
	     objResult.itemsPerPage = json['os:itemsPerPage']

	     objArray = Array.new()
	     json['entries'].each {|item|
		objP = Provider.new()
		objP.load(item)
	  	objArray.push(objP)
	     }
	     return objResult, objArray
	  else		
	     objResult.query = "" 
	     objResult.startIndex = 1
	     objResult.totalResults = 1
	     objResult.itemsPerPage = 1

	     objP = Provider.new()
	     objP.load(json)
	     return objResult, Array(objP)
	  end
	else 
	   opts.delete(:type)
	   @base = URI.parse WORLDCAT_KB_URL + "providers/search"
	   data = do_request(opts)
	   json = JSON.parse(data)
  	   objResult = Result.new()
	   objResult.query = json['os:Query'] 
	   objResult.startIndex = json['os:startIndex']
	   objResult.totalResults = json['os:totalResults']
	   objResult.itemsPerPage = json['os:itemsPerPage']

	   objArray = Array.new()
	   json['entries'].each {|item|
	      objP = Provider.new()
	      objP.load(item)
	      objArray.push(objP)
	   }
	   return objResult, objArray
	end
    end

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
 	  objResult = Result.new()
	  objResult.query = "" 
	  objResult.startIndex = 1
	  objResult.totalResults = 1
	  objResult.itemsPerPage = 1

	  objC = Collection.new()
          objC.load(json)
          return objResult, Array(objC) 
       else
	  opts.delete(:type)
	  @base = URI.parse WORLDCAT_KB_URL + "collections/search"
          data = do_request(opts)
          json = JSON.parse(data)
	  objResult = Result.new()
	  objResult.query = json['os:Query']
	  objResult.startIndex = json['os:startIndex']
	  objResult.totalResults = json['os:totalResults']
	  objResult.itemsPerPage = json['os:itemsPerPage']

          objArray = Array.new()
          json['entries'].each {|item|
	    objC = Collection.new()
            objC.load(item)
	    objArray.push(objC)     
          }
	  return objResult, objArray
       end
    end

    def SearchCollections(opts={})
        opts[:type] = 'search'
	return GetCollectionInfo(opts)
    end


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
      puts uri.to_s
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
