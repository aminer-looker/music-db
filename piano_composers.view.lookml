- view: piano_composers
  derived_table:
    sql: |
      SELECT DISTINCT
        c.id,
        c.first_name,
        c.last_name,
        c.url
      FROM
        composers c
      JOIN works w ON w.composer_id = c.id
      JOIN instruments i ON w.instrument_id = i.id
      WHERE
        i.name like '%piano%'
    indexes: [id]
    persist_for: 24 hours

  fields:
  
  - dimension: id
    primary_key: true
    hidden: true

  - dimension: first_name

  - dimension: last_name
  
  - dimension: full_name
    sql: concat(${TABLE}.first_name, ' ', ${TABLE}.last_name)

  - dimension: url
    hidden: true

  - measure: count
    type: count
    drill_fields: [first_name, last_name, works.count]