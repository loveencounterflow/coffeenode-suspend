

### forked from https://github.com/jmar777/suspend. ###


#-----------------------------------------------------------------------------------------------------------
suspend = ( generator, options ) ->
  ### Like `https://github.com/jmar777/suspend`, but:
  * written in CoffeeScript;
  * works with callback-accepting *synchronous* functions (see below comment);
  * this means using `suspend` (or `step`) will make your code asynchronous in case it wasn't already;
  * will throw errors in the generator by default;
  * will send only a single value (not a list with a single value) to the generator if the function calling
    back did so with a single argument (otherwise no change);
  * offers utility functions for your asynchronous chores (available as `suspend.step`, `suspend.after`, and
    `suspend.eventually`);
  * more utilities possible in the future. ###
  do_throw = options?[ 'throw' ] ? yes
  #.........................................................................................................
  return ->
    #.......................................................................................................
    Array::unshift.call arguments, ( error ) ->
      _arguments = arguments
      #.....................................................................................................
      ### Here we postpone sending errors and values until the next turn of the event loop; this will
      prevent `Generator is already running` errors in case a non-asynchronous function happened to be
      called. ###
      suspend.eventually ->
        if do_throw
          return iterator.throw error if error?
          if _arguments.length < 3
            iterator.next _arguments[ 1 ]
          else
            iterator.next Array::slice.call _arguments, 1
        else
          iterator.next Array::slice.call _arguments
    #.......................................................................................................
    iterator = generator.apply this, arguments
    iterator.next()

#-----------------------------------------------------------------------------------------------------------
suspend.step = ( stepper ) ->
  ### Like `suspend`, but executing the suspended function immediately. ###
  R = suspend stepper
  #.........................................................................................................
  return R()

#-----------------------------------------------------------------------------------------------------------
suspend.after = ( time_s, handler ) ->
  ### `after` is a shim for `setTimeout` that adheres to NodeJS conventions, taking a `handler`
  callback function as last argument. Also, the timeout is given in humane seconds rather than in ms. ###
  return setTimeout handler, time_s * 1000

#-----------------------------------------------------------------------------------------------------------
suspend.eventually = ( handler ) ->
  ### `eventually f` is just another name for `process.nextTick f`—which in turn is basically equivalent to
  `after 0, f`. ###
  return process.nextTick handler

#-----------------------------------------------------------------------------------------------------------
suspend.immediately = ( handler ) ->
  ### `immediately f` is just another name for `setImmediate f`, which is very similar to
  `process.nextTick`. ###
  return process.nextTick handler

#-----------------------------------------------------------------------------------------------------------
suspend.every = ( time_s, handler ) ->
  ### `every` is a shim for `setIntervall` that adheres to NodeJS conventions, taking a `handler`
  callback function as last argument. Also, the timeout is given in humane seconds rather than in ms. ###
  return setInterval handler, time_s * 1000

#-----------------------------------------------------------------------------------------------------------
suspend.collect = ( method, P..., handler ) ->
  ### `collect` is a convenience method for asynchronous functions that comply with the following interface:
  * They accept a number of arguments, the last of whioch is a callback handler.
  * The callback handler accepts an `error` and one or more `data` arguments.
  * The function will call with an unspecified number of data items.
  * After the last callback has fired, one more callback with no data item or a a single `undefined` or
    `null` is fired to signal termination.
  * When termination has been signalled and after an error has occurred, no more callbacks are performed.

  `collect` will collect all values in a list, which will be sent to the callback handler; there will be no
  extra call to signal completion. Each time `collect` receives data, it looks whether it has received one
  or more arguments; if there was one argument, that argument will be pushed into the rsults list; if there
  were more arguments, a list with those values is pushed. The number of data items may differ from callback
  to callback.

  Usage example:

      step ( resume ) ->*
        lines = yield collect read_lines_of, route, resume
        log lines

  Mind the comma after the function name in the example—that function must be passed as the first argument,
  not called at this point in time. Also Remeber that in JavaScript, passing `library.method` will in most
  cases make `method` 'forget' about its `this` context, in this case `library`. As a workaround, you may
  want to write

      lines = yield collect ( library.read_lines_of.bind library ), route, resume

  instead. This is a well-known, if unfortunate fact about JavaScript; proposals on how to better deal with
  this situation are welcome. ###
  Z             = []
  has_finished  = no
  #.........................................................................................................
  finish = ->
    has_finished  = yes
    handler null, Z
  #.........................................................................................................
  method P..., ( error, data... ) ->
    throw new Error "`collect` was called after having finished" if has_finished
    return handler error if error?
    switch data.length
      when 0
        finish()
      when 1
        first_item    = data[ 0 ]
        first_item   ?= null
        return finish() if first_item is null
        Z.push first_item
      else
        Z.push data
  #.........................................................................................................
  return null


############################################################################################################
module.exports = suspend

