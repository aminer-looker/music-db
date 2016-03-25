- view: instruments
  fields:

  - dimension: id
    primary_key: true
    hidden: true

  - dimension: name

  - measure: count
    type: count
    drill_fields: [name, works.count]
