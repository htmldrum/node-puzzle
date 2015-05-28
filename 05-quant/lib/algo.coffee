###*
 * This is heart of our trading bot. Function below is called
 * for every candle from the history. As a result an order is
 * expected, however not mandatory.
 *
 * Our dummy algorithm works as following:
 *  - in 1/3 of cases we sell $1
 *  - in 1/3 of cases we buy $1
 *  - in 1/3 of cases we do nothing
 *
 * @param {float}   [price]   Average (weighted) price
 * @param {Object}  [candle]  Candle data with `time`, `open`, `high`, `low`, `close`,
 *                            `volume` values for given `time` interval.
 * @param {Object}  [account] Your account information. It has _realtime_ balance of USD and BTC
 * @returns {object}          An order to be executed, can be null
###

# Opening balance { account: { USD: 1000, BTC: 0 } }
# price 371.38
# candle { time: Sun Nov 30 2014 00:00:00 GMT+1100 (AEDT),
#   open: 373.657,
#   high: 374.316,
#   low: 370.004,
#   close: 371.74,
#   volume: 179.4,
#   avgPrice: 371.38 }
# account { USD: 1000, BTC: 0 }

HOURS_IN_DAY = 24
MOVING_AVERAGE_WINDOW = 100

MAX = 50
MIN = 1

candles = []
t = 0

exports.tick = (price, candle, account) ->

  candles.push(candle)

  average_price = moving_average()
  
  average_close = moving_close()

  # http://www.investopedia.com/articles/active-trading/101014/basics-algorithmic-trading-concepts-and-examples.asp
  amount = volume_weighted_amount()

  is_bull = _is_bull()

  t++

  if candles.length > HOURS_IN_DAY * MOVING_AVERAGE_WINDOW

    if price <= average_price and !is_bull and account.BTC > amount then return buy: amount

    if price >= average_price and is_bull and account.USD > price / amount then return sell: amount

  return null # do nothing

moving_close = () ->
  window = HOURS_IN_DAY * MOVING_AVERAGE_WINDOW

  avg = 0                  
  for i in [0..window]
      avg += candles[t-i].close if candles[t-i]

  return avg/i

moving_average = () ->

  window = HOURS_IN_DAY * MOVING_AVERAGE_WINDOW

  avg = 0                  
  for i in [0..window]
      avg += candles[t-i].avgPrice if candles[t-i]

  return avg/i

volume_weighted_amount = () ->
  window = HOURS_IN_DAY * MOVING_AVERAGE_WINDOW

  avg = 0                  
  for i in [0..window]
      avg += candles[t-i].volume if candles[t-i]

  return (MAX-MIN)*(candles[t].volume/avg)

_is_bull = () -> 
  (candles[t].close - candles[t].high) > (candles[t].low - candles[t].open)