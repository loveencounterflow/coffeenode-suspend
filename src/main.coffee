

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
            iterator.send _arguments[ 1 ]
          else
            iterator.send Array::slice.call _arguments, 1
        else
          iterator.send Array::slice.call _arguments
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
  ### `after` is a thin shim around `setTimeout` that adheres to NodeJS conventions, taking a `handler`
  callback function as last argument. Also, the timeout is given in humane seconds rather than in ms. ###
  return setTimeout handler, time_s * 1000

#-----------------------------------------------------------------------------------------------------------
suspend.eventually = ( handler ) ->
  ### `eventually f` is just another name for `process.nextTick f`—which in turn is basically equivalent to
  `after 0, f`. ###
  return process.nextTick handler


# module.exports = require '../lib/main.js'
module.exports = suspend

