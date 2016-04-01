- view: composers
  fields:

  - dimension: id
    primary_key: true
    hidden: true

  - dimension: first_name

  - dimension: last_name
  
  - dimension: full_name
    required_fields: [composers.url]
    sql: concat(${TABLE}.first_name, ' ', ${TABLE}.last_name)

  - dimension: url
    hidden: true

  - measure: count
    type: count
    drill_fields: [first_name, last_name, works.count]
