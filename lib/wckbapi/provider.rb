module WCKBAPI

  class Provider
    attr_accessor :id, :title, :provider_uid, :provider_name, :avaiable_entries, :selected_entries, :available_collections

    def initialize()
    end
    def load(item)
	@id = item['id']
   	@title = item['title']
 	@provider_uid = item['kb:provider_uid']
	@provider_name = item['kb:provider_name']
	@available_entries = item['kb:available_entries']
	@selected_entries = item['kb:selected_entries']
	@available_collections = item['kb:available_collections']
    end
  end
end
