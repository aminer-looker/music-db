- connection: classical_music_db

- include: "*.view.lookml"       # include all the views
- include: "*.dashboard.lookml"  # include all the dashboards

- explore: composers
  
- explore: works
  joins:
    - join: instruments
      foreign_key: instrument_id

    - join: types
      foreign_key: type_id

    - join: composers
      foreign_key: composer_id

    - join: collections
      foreign_key: collection_id
