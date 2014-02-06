module WCKBAPI

  class Entry
    attr_accessor :id, :title, :entry_uid, :entry_status, :bkey, :collection_name, :collection_uid, :provider_uid, :provider_name, :oclcnum, :author, :isbn, :publisher, :coverage, :uri

    def initialize()
    end
    def load(item)
	@id = item['id']
   	@title = item['title']
	@entry_uid = item['entry_uid']
	@entry_status = item['entry_status']
	@bkey = item['bkey']
	@collection_name = item['kb:collection_name']
	@collection_uid = item['kb:collection_uid']
 	@provider_uid = item['kb:provider_uid']
	@provider_name = item['kb:provider_name']
	@oclcnum = item['kb:oclcnum']
	@author = item['kb:author']
	@isbn = item['kb:isbn']
	@publisher = item['kb:publisher']
	@coverage = item['kb:coverage']
  	item['links'].each {|t|
	   if t['rel'] == 'via'
	     @uri = t['href']
	   end 
	}
    end
  end
end
