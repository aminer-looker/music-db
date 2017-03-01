view: instruments {
  dimension: id {
    primary_key: yes
    hidden: yes
  }

  dimension: name {}

  measure: count {
    type: count
    drill_fields: [name, works.count]
  }
}
