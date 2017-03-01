view: composers {
  dimension: id {
    primary_key: yes
    hidden: yes
  }

  dimension: first_name {}
  dimension: last_name {}

  dimension: full_name {
    required_fields: [composers.url]
    sql: concat(${TABLE}.first_name, ' ', ${TABLE}.last_name) ;;
    html: <a href="http://www.google.com/#q={{value}}">{{value}}</a> ;;
  }

  dimension: url {
    hidden: yes
  }

  measure: count {
    type: count
    drill_fields: [first_name, last_name, works.count]
  }
}
