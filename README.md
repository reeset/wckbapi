wckbapi
=====

WorldCat Knowledge Base API ruby library


Dependencies:
* nokogiri
* json

*********************** Functions *********************************

GetEntry
 * params -- :id, :entry_uid, :collection_uid
 * returns -- Result Object, Entry Object
 

SearchEntries
 * params -- :title, :startIndex, :itemsPerPage, :content
 * returns -- Result Object, Array[Entry Object]
 

SearchProviders, GetProviderInfo
 * params -- :title, :collection_uid
 * returns -- Result Object, Array[Providers Object]
 
SearchCollections, GetCollectionInfo
 * params -- :title, :institution_id, :collection_uid, :itemsPerPage, :startIndex
 * returns -- Result Object, Array[Collection Object]
 

Note, these functions can accept any parameters supported by the OCLC Knowledge Base API -- however, these are likely the most relevant for most people.  
 * API Documentation: http://www.oclc.org/developer/services/worldcat-knowledge-base-api
 

Questions? Comments?
 * reeset[at]gmail[dot]com
