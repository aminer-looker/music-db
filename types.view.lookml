- view: types
  fields:

  - dimension: id
    primary_key: true
    type: int
    hidden: true

  - dimension: name

  - measure: count
    type: count
    drill_fields: [name, works.count]
