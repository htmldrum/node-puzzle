fs = require 'fs'


GEO_FIELD_MIN = 0
GEO_FIELD_MAX = 1
GEO_FIELD_COUNTRY = 2


exports.ip2long = (ip) ->
  ip = ip.split '.', 4
  return +ip[0] * 16777216 + +ip[1] * 65536 + +ip[2] * 256 + +ip[3]


gindex = []
exports.load = ->
  data = fs.readFileSync "#{__dirname}/../data/geo.txt", 'utf8'
  data = data.toString().split '\n'

  for line in data when line
    line = line.split '\t'
    # GEO_FIELD_MIN, GEO_FIELD_MAX, GEO_FIELD_COUNTRY
    gindex.push [+line[0], +line[1], line[3]]

normalize = (row) -> country: row[GEO_FIELD_COUNTRY]

exports.lookup = (ip) ->
  return -1 unless ip

  find = this.ip2long ip
  return bin_s(find,gindex,0,gindex.length-1)

bin_s = (needle,haystack,min,max) ->

  mid = (max+min)//2

  if max < min
    return null
  else if needle > haystack[mid][GEO_FIELD_MAX]
    return bin_s(needle,haystack,(mid+1),max)
  else if needle < haystack[mid][GEO_FIELD_MIN]
    return bin_s(needle,haystack,min,(mid-1))
  else if needle >= haystack[mid][GEO_FIELD_MIN] and needle <= haystack[mid][GEO_FIELD_MAX]
    return normalize haystack[mid]
