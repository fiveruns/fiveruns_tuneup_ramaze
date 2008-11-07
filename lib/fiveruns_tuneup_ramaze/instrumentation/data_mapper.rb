module Fiveruns::Tuneup::Ramaze
  
  def self.pretty(value)
    CGI.escapeHTML(PP.pp(value, ''))
  end

  def self.format_sql(query, statement, attributes = nil)
    values = query.bind_values + (attributes ? attributes.values : [])
    [statement, "<b>Values:</b> " + CGI.escapeHTML(values.inspect)].join("<br/>")
  end
  
  def self.attrs_for(query)
    [
      [ :repository, query.repository.name ],
      [ :model,      query.model           ],
      [ :fields,     query.fields          ],
      [ :links,      query.links           ],
      [ :conditions, query.conditions      ],
      [ :order,      query.order           ],
      [ :limit,      query.limit           ],
      [ :offset,     query.offset          ],
      [ :reload,     query.reload?         ],
      [ :unique,     query.unique?         ]
    ]
  end
  
  def self.format_query(query)
    rows = attrs_for(query).map do |set|
      %(<tr><th>%s</th><td><pre>%s</pre></td></tr>) % set.map { |item|
        pretty item
      }
    end
    "<table>%s</table>" % rows.join
  end
  
end

Fiveruns::Tuneup::Superlative.on DataMapper::Repository, :instances do
  def read_many(query)
     Fiveruns::Tuneup.step("DM Read Many", :model,
       'Query' => [
         Fiveruns::Tuneup::Ramaze.format_sql(query, adapter.send(:read_statement, query)),
         {'Raw Details' => Fiveruns::Tuneup::Ramaze.format_query(query)}
       ]
     ) { super }
   end

   def read_one(query)
     Fiveruns::Tuneup.step("DM Read One ", :model,
       'Query' => [
         Fiveruns::Tuneup::Ramaze.format_sql(query, adapter.send(:read_statement, query)),
         {'Raw Details' => Fiveruns::Tuneup::Ramaze.format_query(query)}
        ]
     ) { super }
   end

   def update(attributes, query)
     Fiveruns::Tuneup.step("DM Update", :model,
       'Query' => [
         Fiveruns::Tuneup::Ramaze.format_sql(query, adapter.send(:update_statement, query), attributes),
         {'Raw Details' => Fiveruns::Tuneup::Ramaze.format_query(query)}
        ]
     ) { super }
   end

   def delete(query)
     Fiveruns::Tuneup.step("DM Delete", :model,
       'Query' => [
         Fiveruns::Tuneup::Ramaze.format_sql(query, adapter.send(:delete_statement, query)),
         {'Raw Details' => Fiveruns::Tuneup::Ramaze.format_query(query)}
       ]
     ) { super }
   end
end