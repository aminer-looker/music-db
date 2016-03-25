- view: collections
  fields:
  
  - dimension: id
    primary_key: true
    hidden: true

  - dimension: composer_id
    hidden: true
  
  - dimension: composer
    sql: ${composers.full_name}

  - dimension: title
    required_fields: [collections.id]
    html: |
      <a href="https://localhost:9999/explore/classical_music_db/works?vis=%7B%7D&show=data,fields&query=R6799Ky&filter_config=%7B%22collections.title%22:%5B%7B%22type%22:%22contains%22,%22values%22:%5B%7B%22constant%22:%22{{row["collections.title"]}}%7D,%7B%7D%5D,%22id%22:3%7D%5D%7D&f%5Bcollections.title%5D=%25{{row["collections.title"]}}%25" target="new">
        <img
          src="http://www.looker.com/favicon.ico"
          style="height: 16px; width: 16px"
        >
        {{value}}
      </a>

  - dimension: url
    hidden: true

  - measure: count
    type: count
    drill_fields: [title, composer.full_name, works.count]

  sets:
    collection_work_detail:
      - work.title
      - work.composer
      - work.catalog_name
