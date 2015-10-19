- view: composers
  fields:

  - dimension: id
    primary_key: true
    type: int
    hidden: true

  - dimension: first_name

  - dimension: last_name
  
  - dimension: full_name
    required_fields: [composers.url]
    sql: concat(${TABLE}.first_name, ' ', ${TABLE}.last_name)
    html: |
      <a href="//www.classicalmusicdb.com{{row["composers.url"]}}" target="new">
        <img
          src="//www.classicalmusicdb.com/CMDB_favicon.gif"
          style="height: 16px; width: 16px"
        >
        {{value}}
      </a>

  - dimension: url
    hidden: true

  - measure: count
    type: count
    drill_fields: [first_name, last_name, works.count]
