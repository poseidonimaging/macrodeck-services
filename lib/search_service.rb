# This service provides search functionality. Its based on Ferret and works
# using AR.

class SearchService < BaseService

#  def SearchService.search_old(items,query,where=['title'])
#      case items[0].instance_of?
#        when DataItem, ProfileItem
#          metadata_method = lambda {|i| DataService.getDataItemMetadata(i.id) }
#        when DataGroup, Profile
#          metadata_method = lambda {|i| DataService.getDataGroupMetadata(i.id) }
#        when Storage
#          metadata_method = lambda {|i| StorageService.getFileMetadata(i.id) }
#        else
#          metadata_method = lambda {|i| i.attributes}
#      end
#      fields = parse_where(where)
#      lfunc, keywords = parse_query(query)
#      inv_search_table, search_table = prepare_search_tables
#      res = {}
#      where.each {|field|
#          col = keywords.collect {|word| inv_search_table[word][field]}
#          res[field] = []
#          lfunc.call(col).each { |i|
#              res[field].push(Hash[:item =>fields[i], :relevance=> 50.0,
#              :metadata => metadata_method.call(field[i])])
#          }
#      }
#      res
#  end
  
  # This is the main method of the service. Array of hashes is returned - 
  # { :item => AR object,
  #   :relevance => relevance score,
  #   :metadata => Metadata hash
  # }
  # 
  # +items+:: array of AR objects
  # +query+:: query string
  # === Options
  #   where::       columns which we will verify,
  #                 [:tags,:description,:title] by default
  #   index::       type of index,
  #                 'AR' - we will use exist index of AR model (acts_as_ferret provides it)
  #                 'memory' - we will create new index in memory
  #   highlight::   if it is true, matches in 'description' field will be highlighted
  #                 and result will be accessible via :highlight keyword
  #                 
  # === Example
  # 1) SearchService.search(items,"description|title: Bill ~Gates") 
  #   returns items conain Bill and don't contain Gates
  # 2) SearchService.search(items,"title: news AND tags: (USA OR RUSSIA)") 
  #   returns all items contain news in title and USA or RUSSIA tags  
  def SearchService.search(items,query,options={:index => "AR"})

      # XXX: probably this raises should be removed after testing                          
      raise "items should be instance of Array" unless items.instance_of? Array
      raise "query should be instance of String" unless query.instance_of? String
      return nil unless (items or !item.empty?)
      return items unless (query or !query.empty?)

      place = {}
      score = 0.0
      
      options[:where] = [:tags,:description,:title] unless options[:where]
      options[:highlight] = false unless options[:highlight]

      case options[:index]
      when "AR":
          model = items[0].class
          index = model.ferret_index
          selection = items.collect {|item| item.id}

          selection_proc = Proc.new {|doc_id,sc,searcher|             
              score = sc
              place[doc_id] = selection.index(searcher[doc_id][:id].to_i)              
          }
      when "memory":
          index = Ferret::Index::Index.new
          for item in items do
            index << item.attributes(:only=>options[:where])
            place[index.size-1] = index.size-1  
          end
      end
      
      result = []

      index.search_each(query,{:filter_proc => selection_proc}) do |id,sc|
                      
          item = items[place[id]]
          metadata = item.attributes(:only=>options[:where])
          hit =  {:item => item,
                  # FIXME: it is probably ferret bug
                  # when we use filter_proc we always get score = 0.0 inside
                  # search_each
                  :relevance=> sc == 0.0 ? score : sc, 
                  :metadata=>metadata}              
          if options[:highlight]
              hit[highlight] = index.highlight(query,0,:field=>:description)
          end
          result << hit                  
      end
      result
      
  end
  
#  private
#  
#  def parse_query(query)
#      raise "query's type should be String" unless query.kind_of? String
#      lex = query.split
#      terms = []
#      ops = []
#      lex.each {|word|
#          case word
#              when "AND"
#                  ops.push("&")
#              when "OR"
#                  ops.push("|")
#              else
#                  terms.push(word)                  
#          end
#      }
#      [ops.size > 0 ? lambda_gen(ops) : nil, terms]
#  end
#  
#  def parse_where(where)
#      where
#  end
#
#  def lambda_gen(ops)
#      t = Array.new
#      ops.each {|op|
#          t.push(lambda {|t1,t2| t1.send(op,t2)})
#      }
#      lambda {|args|
#          arg1 = args.shift
#          i = 1
#          while !args.empty?
#              arg2 = args.shift
#              arg3 = t[i-1].call(arg1,arg2)
#              i += 1
#              arg1 = arg3
#          end
#          arg1
#      }
#  end
#
#  def relevent_of(data,keywords)
#      data.split
#  end
#
#  def prepare_search_tables(items,fields)
#      inv_search_table = Hash.new
#      search_table = Hash.new
#      items.each {|item|
#          item.attributes(:only=>fields).each {|attr, value|
#              value.to_s.split.each {|keyword|
#                  if !inv_search_table.has_key?(keyword)
#                      inv_search_table[keyword] = Hash.new
#                      inv_search_table[keyword][attr] = Array.new
#                  elsif !inv_search_table[keyword].has_key?(attr)
#                      inv_search_table[keyword][attr] = Array.new
#                  end
#                  inv_search_table[keyword][attr].push(items.index(item))
#                  search_table[items.index(item)][attr][keyword] = 0
#              }
#          }
#      }
#      [inv_search_table, search_table]
#  end
#  

end
