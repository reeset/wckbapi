module WCKBAPI

  class Collection
    attr_accessor :id, :title, :provider_uid, :provider_name, :avaiable_entries, :selected_entries, :collection_name, :collection_uid, :owner_institution, :source_institution, :status, :dbkey, :source, :open, :collection_type

    def initialize()
    end
    def load(item)
	@id = item['id']
   	@title = item['title']
 	@provider_uid = item['kb:provider_uid']
	@provider_name = item['kb:provider_name']
	@available_entries = item['kb:available_entries']
	@selected_entries = item['kb:selected_entries']
	@collection_name = item['kb:collection_name']
	@collection_uid = item['kb:collection_uid']
	@owner_institution = item['kb:owner_institution']
	@source_institution = item['kb:source_institution']
	@status = item['kb:status']
	@dbkey = item['kb:dbkey']
	@source = item['kb:source']
	@open = item['kb:open']
	@collection_type = item['kb:collection_type']
    end
  end
end
