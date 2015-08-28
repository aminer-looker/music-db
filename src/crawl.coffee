_       = require('underscore')
cheerio = require('cheerio')
http    = require('crafting-guide-common').http
mysql   = require('promise-mysql')
w       = require('when')

########################################################################################################################

BASE_URL = 'http://www.classicalmusicdb.com:80'
db = null
queue = null

########################################################################################################################

class Queue
    
    constructor: ->
        @_workItems = []
        @_workFunctions = {}
    
    empty: ->
        return w(true) unless @_workItems.length > 0
        workItem = @_workItems.shift()
            
        w.promise (resolve, reject)=>
            try
                w(workItem.func.apply null, workItem.args)
                    .then => @empty()
                    .then -> resolve(true)
                    .catch (error)-> reject error
            catch error
                reject error
    
    enqueue: (name, args...)->
        @_workItems.push func:@_lookupFunction(name), args:args
    
    insert: (name, args...)->
        @_workItems.unshift func:@_lookupFunction(name), args:args
    
    register: (name, func)->
        @_workFunctions[name] = func
    
    _lookupFunction: (name)->
        func = @_workFunctions[name]
        if not func? then throw new Error "#{name} isn't a known work function"
        return func

queue = new Queue

########################################################################################################################

connect = ->
    mysql.createConnection host:'localhost', port:3306, user:'root', database:'music'
        .then (c)-> db = c

asDocument = (response)->
    text = response.body.replace('\\n', '\n').replace('\\t', '\t')
    return cheerio.load text

scrubCellText = (object)->
    result = {}
    for own property, value of object
        if _.isString(value)
            value = value.trim()
            value = value.replace(/^-/, '').replace(/-$/, '').replace(/»/g, '').replace(/–/, '').replace(/\s+/g, ' ')
            value = value.trim()
            result[property] = value if value
        if _.isNumber(value)
            result[property] = value unless _.isNaN(value)
        else if _.isObject(value)
            result[property] = value
    
    return result

# Work Methods #########################################################################################################

queue.register 'assignCollection', (collection, work)->
    console.log "assigning collection #{collection.id} to work at #{work.url}"
    
    db.query 'select id from works where url = ?', [work.url]
        .then (result)->
            if result.length is 1
                work.id = result[0].id
                db.query 'update works set collection_id = ? where id = ?', [collection.id, work.id]
                    .then ->
                        console.log "updated collection on work #{work.id}"
        .catch (error)->
            console.error "failed to assign collection #{collection.id}: #{error}"

queue.register 'clearDatabase', ->
    console.log "clearing database"
    
    w(true)
        .then -> db.query 'delete from works'
        .then -> db.query 'delete from collections'
        .then -> db.query 'delete from composers'
        .then -> db.query 'delete from types'
        .then -> db.query 'delete from instruments'

queue.register 'downloadCollectionPage', (collection)->
    console.log "downloading collection page: #{collection.url}"
    
    http.get BASE_URL + collection.url
        .then (response)->
            $ = asDocument response
            
            for linkEl in $('#content li a')
                $link = $(linkEl)
                queue.insert 'assignCollection', collection, url:$link.attr('href')

queue.register 'downloadComposerPage', (composer)->
    console.log "downloading composer page: #{composer.url}"
    
    http.get BASE_URL + composer.url
        .then (response)->
            $ = asDocument response
            
            collections = {}
            for rowEl in $('#composition_table tr')
                $row = $(rowEl)
                
                collection = null
                $collectionCell = $row.find('td[title="Collection"]')
                if $collectionCell.text().length > 1
                    collection = scrubCellText
                        composer: composer
                        title:    $collectionCell.text()
                        url:      $collectionCell.find('a').attr('href')
                    
                    if not collections[collection.title]?
                        collections[collection.title] = collection

                work = scrubCellText
                    collection:  collection
                    composer:    composer
                    difficulty:  parseFloat($row.find('td[title="Aggregated Level"]').text())
                    instrument:  $row.find('td[title="Instrumentation"]').text()
                    opus:        $row.find('td[title="Op."]').text()
                    opusNumber:  $row.find('td[title="No."]').text()
                    title:       $row.find('td:first-child').text()
                    type:        $row.find('td[title="Type"]').contents()?.get(0)?.nodeValue
                    url:         $row.find('td:first-child a').attr('href')

                if work.title?
                    queue.insert 'insertWork', work 
            
            for title, collection of collections
                queue.insert 'insertCollection', collection
                
        .catch (error)->
            console.error "Failed to download page: #{error}"

queue.register 'downloadComposerListPage', (url)->
    console.log "downloading composer listing"
    
    http.get url
        .then (response)->
            $ = asDocument response

            for linkEl in $('#content li a')
                $link = $(linkEl)
                names = (name.trim() for name in $link.text().split(','))
                
                composer = scrubCellText
                    firstName: names[1]
                    lastName: names[0]
                    fullName: "#{names[1]} #{names[0]}"
                    url:      $link.attr('href')
                
                if not composer.fullName.match /Anonymous/
                    queue.insert 'insertComposer', composer
        .catch (error)->
            console.error "Failed to download page: #{error.stack}"

queue.register 'downloadWorkPage', (work)->
    console.log "downloading work page: #{work.url}"
    
    http.get BASE_URL + work.url
        .then (response)->
            $ = asDocument response
            
            for detailRowEl in $('#detailTable tr')
                $detailRow = $(detailRowEl)
                label = $detailRow.find('td:nth-child(1)').text().trim()
                value = $detailRow.find('td:nth-child(2)').text().trim()
                
                switch label
                    when 'Date Composed'   then work.composedYear = value
                    when 'BB'              then work.catalogName  = "BB. #{value}"
                    when 'BWV'             then work.catalogName  = "BWV. #{value}"
                    when 'Hob.'            then work.catalogName  = "H. #{value}"
                    when 'Instrumentation' then work.instrument   = value
                    when 'J.'              then work.catalogName  = "J. #{value}"
                    when 'Key'             then work.keyArea      = value
                    when 'KV'              then work.catalogName  = "KV. #{value}"
                    when 'Sz.'             then work.catalogName  = "Sz. #{value}"
                    when 'Type'            then work.type         = value
                    when 'WWV'             then work.catalogName  = "WWV. #{value}"
                    when 'Z.'              then work.catalogName  = "Z. #{value}"
                
                work = scrubCellText work
                
                if not work.catalogName? and work.opus?
                    if work.opusNumber?
                        work.catalogName = "Op. #{work.opus} No. #{work.opusNumber}"
                    else
                        work.catalogName = "Op. #{work.opus}"
                
                if work.composedYear? and _.isString(work.composedYear)
                    work.composedYear = parseInt(work.composedYear.replace /[0-9]{1,4}$/, "$&")

            queue.insert 'normalizeInstrument', work
        .catch (error)->
            console.error "failed to download work page: #{error}"

queue.register 'insertCollection', (collection)->
    console.log "inserting data for #{collection.title} by #{collection.composer.fullName}"
    
    query = "insert into collections (composer_id, title, url) values (?, ?, ?)"
    db.query query, [collection.composer.id, collection.title, collection.url]
        .then (result)->
            collection.id = result.insertId
            console.log "finished saving collection: #{collection.title}"
        .catch (error)->
            console.error "Failed to insert collection, #{collection.title}: #{error}"

queue.register 'insertComposer', (composer)->
    console.log "inserting data for #{composer.fullName}"
    
    query = 'insert into composers (last_name, first_name, url) values (?, ?, ?)'
    db.query query, [composer.lastName, composer.firstName, composer.url]
        .then (result)->
            composer.id = result.insertId
            queue.enqueue 'downloadComposerPage', composer
        .catch (error)->
            console.log "failed to insert composer, #{composer.fullName}: #{error}"

queue.register 'insertWork', (work)->
    console.log "inserting data for #{work.title} by #{work.composer.fullName}"
    
    query = "insert into works (
        composer_id, collection_id, title, opus, opus_num, difficulty, url
    ) values (
        ?, ?, ?, ?, ?, ?, ?
    )"
    values = [
        work.composer.id, work.collection?.id, work.title, work.opus, work.opusNumber, work.difficulty, work.url
    ]
    
    db.query query, values
        .then (result)->
            work.id = result.insertId
            queue.enqueue 'downloadWorkPage', work
        .catch (error)->
            console.error "failed to insert work, #{work.title}: #{error}"

queue.register 'normalizeInstrument', (work)->
    console.log "normalizing the instrument for #{work.title} by #{work.composer.fullName}"
    
    if not _.isString(work.instrument)
        queue.insert 'normalizeType', work
        return
    
    db.query "select id, name from instruments where name = ?", [work.instrument]
        .then (result)->
            if result.length > 0
                work.instrument = id:result[0].id, name:result[0].name
                queue.insert 'normalizeType', work
            else
                db.query "insert into instruments (name) values (?)", [work.instrument]
                    .then (result)->
                        work.instrument = id:result.insertId, name:work.instrument
                        queue.insert 'normalizeType', work

queue.register 'normalizeType', (work)->
    console.log "normalizing the type (#{work.type}) for #{work.title} by #{work.composer.fullName}"
    
    if not _.isString(work.type)
        queue.insert 'updateWork', work
        return
    
    db.query "select id, name from types where name = ?", [work.type]
        .then (result)->
            if result.length > 0
                work.type = id:result[0].id, name:result[0].name
                queue.insert 'updateWork', work
            else
                db.query "insert into types (name) values (?)", [work.type]
                    .then (result)->
                        work.type = id:result.insertId, name:work.type
                        queue.insert 'updateWork', work

queue.register 'refreshCollections', ->
    console.log "refreshing collections"
    
    db.query 'select id, url from collections'
        .then (result)->
            for collection in result
                queue.enqueue 'downloadCollectionPage', collection

queue.register 'refreshWorkPages', ->
    console.log "refreshing work pages"
    
    query = "select
        w.id,
        w.title,
        w.url,
        w.composed_year as composedYear,
        w.key_area as keyArea,
        w.catalog_name as catalogName,
        w.type_id as typeId,
        w.instrument_id as instrumentId,
        c.first_name as composer_first_name,
        c.last_name as composer_last_name
    from works w join composers c on w.composer_id = c.id
    where c.first_name = 'Johannes' and c.last_name = 'Brahms'"
    
    db.query query
        .then (result)->
            for row in result
                work = row
                work.type = id:work.typeId
                work.instrument = id:work.instrumentId
                work.composer = fullName:"#{work.composer_first_name} #{work.composer_last_name}"
                
                queue.enqueue 'downloadWorkPage', work

queue.register 'updateWork', (work)->
    console.log "saving updated data for #{work.title} by #{work.composer?.fullName}"
    
    query = "update works set
        composed_year = ?,
        key_area = ?,
        catalog_name = ?,
        type_id = ?,
        instrument_id = ?
    where id = ?"
    
    db.query query, [work.composedYear, work.keyArea, work.catalogName, work.type?.id, work.instrument?.id, work.id]
        .then (result)->
            console.log "finished #{work.title} by #{work.composer?.fullName}"
        .catch (error)->
            console.error "failed to update: #{error.stack}"

########################################################################################################################

connect()
    .then ->
        # queue.enqueue 'clearDatabase'
        # queue.enqueue 'downloadComposerListPage', BASE_URL + '/composers'
        # queue.enqueue 'refreshWorkPages'
        queue.enqueue 'refreshCollections'
        queue.empty()
    .catch (error)->
        console.log "ERROR: #{error.stack}"
    .then ->
        process.exit()
    
