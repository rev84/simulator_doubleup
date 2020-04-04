window.maxCount = 1
window.timerContinue = false
window.times = {}
window.historyMin = 0

$().ready ->
  $('#start').on 'click', start
  init()

init = ->
  addLine('total', '合計')
  addLine(0)

start = ->
  window.timerContinue = !window.timerContinue
  go()

go = ->
  return unless window.timerContinue

  deck = makeDeck()

  baseCard = deck.pop()
  count = 0
  history = [baseCard]
  while true
    targetCard = deck.pop()
    decide = decideUpper baseCard
    res = result(baseCard, targetCard, decide)
    history.push(targetCard)
    if res is 'draw'
      continue
    else if not res
      break
    count++
    baseCard = targetCard

  if window.maxCount <= count
    for cnt in [window.maxCount..count]
      addLine(cnt)
    window.maxCount = count+1

  window.times[count]++
  updateLine(count, history)
  updateP()

  setTimeout go, 1

totalTimes = ->
  t = 0
  for key, value of window.times
    t += Number value
  t

decideUpper = (baseCard)->
  c2p(baseCard) <= 6

result = (baseCard, targetCard, decide)->
  return 'draw' if c2p(baseCard) is c2p(targetCard)
  (c2p(baseCard) < c2p(targetCard) and decide) or (c2p(baseCard) > c2p(targetCard) and not decide)


updateP = ->
  total = totalTimes()
  $('tr#line_total').find('td').eq(1).html total.toLocaleString()
  $('tr.count').each ->
    id = $(@).find('th').eq(0).html()
    if window.times[id]?
      $(@).find('td').eq(1).html(window.times[id].toLocaleString())
      $(@).find('td').eq(2).html(sprintf('%.2f', window.times[id] / total * 100)+'%')

updateLine = (count, history)->
  $('tr#line_'+count+' td').eq(3).html(
    if count is 'total' or count < window.historyMin then '' else history.map((v)-> '<img class="card" src="'+c2img(v)+'">').join(',')
  )

addLine = (count, title = null)->
  id = 'line_'+count
  return if $('tr#'+id).length > 0
  title = if title is null then count else title
  tr = $('<tr>')
  .addClass(if count is 'total' then '' else 'count')
  .attr('id', id)
  .append(
    $('<th>').addClass('right').html(title)
  )
  .append(
    $('<td>').addClass('right').html(if count is 'total' then '-' else if count is 0 then 0 else (2**(count-1)).toLocaleString())
  )
  .append(
    $('<td>').addClass('right')
  )
  .append(
    $('<td>').addClass('right')
  )
  .append(
    $('<td>')
  )

  $('tbody').append tr
  window.times[count] = 0


c2p = (c)->
  if 52 <= c
    13
  else
    c % 13
c2img = (c)->
  return './img/jk.png' if 52 <= c
  nums = [2,3,4,5,6,7,8,9,10,11,12,13,1]
  img = './img/'
  img += switch Math.floor(c/13)
    when 0
      'c'
    when 1
      'd'
    when 2
      'h'
    when 3
      's'
  img += sprintf('%02d', nums[c%13])+'.png'
makeDeck = ->
  deck = []
  deck.push(index) for index in [0...54]
  shuffle deck

shuffle = (ary)->
  n = ary.length
  while n
    n--
    i = @rand 0, n
    [ary[i], ary[n]] = [ary[n], ary[i]]
  ary

rand = (min, max)->
  Math.floor(Math.random() * (max - min + 1)) + min